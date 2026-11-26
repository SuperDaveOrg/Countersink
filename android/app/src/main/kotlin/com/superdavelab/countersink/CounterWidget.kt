package com.superdavelab.countersink

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.net.Uri
import android.os.Build
import android.text.TextPaint
import android.view.View
import android.widget.RemoteViews
import kotlin.math.ceil
import kotlin.math.pow

/**
 * The home-screen widget: one counter, in its own colors, with minus and
 * plus. A press counts without opening the app; a touch on the name or the
 * number opens it.
 *
 * Built on Android's own widget classes, with no library, so nothing can
 * merge a permission into the manifest. It needs none: the count is written
 * to the app's own database ([WidgetStore]), and the refresh at the start of
 * a new day is an inexact alarm that doesn't wake the phone.
 */
class CounterWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, widgetIds: IntArray) {
        for (id in widgetIds) render(context, manager, id)
        scheduleNewDay(context)
    }

    /** Resized: a narrow widget stacks its buttons under the number. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int,
        newOptions: android.os.Bundle?,
    ) = render(context, manager, widgetId)

    override fun onDeleted(context: Context, widgetIds: IntArray) =
        WidgetStore.forget(context, widgetIds)

    /** The last widget is gone: nothing left to refresh. */
    override fun onDisabled(context: Context) {
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
            .cancel(newDayIntent(context))
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_ADD, ACTION_TAKE -> {
                val widgetId = intent.getIntExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_ID,
                    AppWidgetManager.INVALID_APPWIDGET_ID,
                )
                val counterId = WidgetStore.counterFor(context, widgetId) ?: return
                // Off the main thread, and kept alive until it's written.
                val pending = goAsync()
                Thread {
                    try {
                        WidgetStore.count(
                            context,
                            counterId,
                            if (intent.action == ACTION_ADD) 1 else -1,
                        )
                        updateAll(context)
                    } finally {
                        pending.finish()
                    }
                }.start()
            }
            // Added from inside the app, which already knows the counter.
            ACTION_PINNED -> {
                val widgetId = intent.getIntExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_ID,
                    AppWidgetManager.INVALID_APPWIDGET_ID,
                )
                val counterId = intent.getStringExtra(EXTRA_COUNTER)
                if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID && counterId != null) {
                    WidgetStore.setCounter(context, widgetId, counterId)
                    updateAll(context)
                }
            }
            // A new counting day, or the clock or time zone was changed.
            ACTION_NEW_DAY,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            -> updateAll(context)
            else -> super.onReceive(context, intent)
        }
    }

    companion object {
        private const val ACTION_ADD = "com.superdavelab.countersink.widget.ADD"
        private const val ACTION_TAKE = "com.superdavelab.countersink.widget.TAKE"
        private const val ACTION_NEW_DAY = "com.superdavelab.countersink.widget.NEW_DAY"
        const val ACTION_PINNED = "com.superdavelab.countersink.widget.PINNED"
        const val EXTRA_COUNTER = "counter"

        /** Narrower than this, in dp, the buttons go under the number. */
        private const val WIDE = 170

        /** The family's clay, for a widget with no counter to take color from. */
        private const val CLAY = 0xFFC4613F.toInt()

        /** Dark ink for words on a light card; white goes on a dark one. */
        private const val INK = 0xFF14232E.toInt()

        private fun mutable() = if (Build.VERSION.SDK_INT >= 31) PendingIntent.FLAG_MUTABLE else 0

        /** Every widget on the home screen, brought up to date. */
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, CounterWidget::class.java))
            for (id in ids) render(context, manager, id)
            if (ids.isNotEmpty()) scheduleNewDay(context)
        }

        /**
         * Asks the home screen to add a widget for [counterId], from inside
         * the app. False if this home screen can't be asked.
         */
        fun pin(context: Context, counterId: String): Boolean {
            if (Build.VERSION.SDK_INT < 26) return false
            val manager = AppWidgetManager.getInstance(context)
            if (!manager.isRequestPinAppWidgetSupported) return false
            // The home screen fills in the new widget's id, so this one has
            // to be left open to it.
            val added = PendingIntent.getBroadcast(
                context,
                0,
                Intent(context, CounterWidget::class.java)
                    .setAction(ACTION_PINNED)
                    .setData(Uri.parse("countersink://widget/pin/$counterId"))
                    .putExtra(EXTRA_COUNTER, counterId),
                PendingIntent.FLAG_UPDATE_CURRENT or mutable(),
            )
            return manager.requestPinAppWidget(
                ComponentName(context, CounterWidget::class.java),
                null,
                added,
            )
        }

        fun canPin(context: Context): Boolean =
            Build.VERSION.SDK_INT >= 26 &&
                AppWidgetManager.getInstance(context).isRequestPinAppWidgetSupported

        private fun render(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val words = WidgetStore.localized(context)
            val counterId = WidgetStore.counterFor(context, widgetId)
            val counter = counterId?.let { WidgetStore.read(context, it) }
            val views = if (counter == null) {
                // Nothing chosen yet, or the counter has since been deleted:
                // either way a touch opens the list to choose from.
                RemoteViews(context.packageName, R.layout.widget_empty).apply {
                    setInt(R.id.widget_bg, "setColorFilter", CLAY)
                    setTextViewText(
                        R.id.widget_message,
                        words.getString(
                            if (counterId == null) R.string.widget_choose else R.string.widget_gone,
                        ),
                    )
                    setOnClickPendingIntent(R.id.widget_root, chooseIntent(context, widgetId))
                }
            } else {
                val width = manager.getAppWidgetOptions(widgetId)
                    .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
                counterViews(
                    context,
                    words,
                    widgetId,
                    counter,
                    if (width >= WIDE) R.layout.widget_counter else R.layout.widget_counter_small,
                )
            }
            manager.updateAppWidget(widgetId, views)
        }

        private fun counterViews(
            context: Context,
            words: Context,
            widgetId: Int,
            counter: WidgetCounter,
            layout: Int,
        ) = RemoteViews(context.packageName, layout).apply {
            val ink = inkOn(counter.color, counter.color2)
            // The card's color, and the second one blended in from the far
            // corner if it has one. Patterns are left to the app.
            setInt(R.id.widget_bg, "setColorFilter", counter.color)
            if (counter.color2 != null) {
                setViewVisibility(R.id.widget_blend, View.VISIBLE)
                setInt(R.id.widget_blend, "setColorFilter", counter.color2)
            } else {
                setViewVisibility(R.id.widget_blend, View.GONE)
            }

            setTextViewText(R.id.widget_name, counter.name)
            setTextColor(R.id.widget_name, ink)
            val number = counter.value.toString()
            setImageViewBitmap(R.id.widget_value, drawNumber(context, number, ink))
            setContentDescription(R.id.widget_value, number)

            for (button in intArrayOf(R.id.widget_minus_bg, R.id.widget_plus_bg)) {
                setInt(button, "setColorFilter", ink)
                setInt(button, "setImageAlpha", 41)
            }
            setInt(R.id.widget_plus_icon, "setColorFilter", ink)
            setInt(R.id.widget_minus_icon, "setColorFilter", ink)
            // A tally doesn't go below nothing: minus is faint at zero, and
            // pressing it does nothing.
            val canTake = counter.value > 0
            setInt(R.id.widget_minus_icon, "setImageAlpha", if (canTake) 255 else 97)

            setContentDescription(
                R.id.widget_plus,
                words.getString(R.string.widget_add, counter.step, counter.name),
            )
            setContentDescription(
                R.id.widget_minus,
                words.getString(R.string.widget_take, counter.step, counter.name),
            )
            setOnClickPendingIntent(R.id.widget_plus, countIntent(context, widgetId, ACTION_ADD))
            setOnClickPendingIntent(R.id.widget_minus, countIntent(context, widgetId, ACTION_TAKE))
            setOnClickPendingIntent(R.id.widget_name, openIntent(context))
            setOnClickPendingIntent(R.id.widget_value, openIntent(context))
        }

        /**
         * The number as a picture, in the app's own serif.
         *
         * A widget is drawn by the home screen, not by the app, and the home
         * screen can only use the phone's fonts. So the number, which is
         * what gives the card its look, is drawn here and handed over as an
         * image; the widget scales it to the room it has. The name stays
         * ordinary text, in the phone's font, so it follows the phone's text
         * size.
         */
        private fun drawNumber(context: Context, text: String, ink: Int): Bitmap {
            val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                color = ink
                // Drawn large, so it stays sharp when a tall widget shows it
                // big; a small one scales it down.
                textSize = 56f * context.resources.displayMetrics.density
                typeface = serif(context)
                // The weight the app's cards use.
                if (Build.VERSION.SDK_INT >= 26) fontVariationSettings = "'wght' 560"
            }
            val metrics = paint.fontMetrics
            val width = ceil(paint.measureText(text)).toInt().coerceAtLeast(1)
            val height = ceil(metrics.descent - metrics.ascent).toInt().coerceAtLeast(1)
            val picture = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            Canvas(picture).drawText(text, 0f, -metrics.ascent, paint)
            return picture
        }

        private var serifFace: Typeface? = null

        /** Fraunces, the app's serif; before Android 8, the phone's own. */
        private fun serif(context: Context): Typeface {
            serifFace?.let { return it }
            val face = try {
                if (Build.VERSION.SDK_INT >= 26) context.resources.getFont(R.font.fraunces) else null
            } catch (_: Exception) {
                null
            } ?: Typeface.create(Typeface.SERIF, Typeface.BOLD)
            serifFace = face
            return face
        }

        /**
         * White or dark ink for words on a card, judged at the middle of a
         * blend: whichever stands out more. The same rule as the app's cards.
         */
        private fun inkOn(color: Int, color2: Int?): Int {
            fun channel(shift: Int): Double {
                val a = (color shr shift) and 0xFF
                val b = if (color2 == null) a else (color2 shr shift) and 0xFF
                val c = (a + b) / 2.0 / 255.0
                return if (c <= 0.03928) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)
            }
            fun luminance(r: Double, g: Double, b: Double) = 0.2126 * r + 0.7152 * g + 0.0722 * b
            val fill = luminance(channel(16), channel(8), channel(0))
            fun linear(v: Int): Double {
                val c = v / 255.0
                return if (c <= 0.03928) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)
            }
            val dark = luminance(
                linear((INK shr 16) and 0xFF),
                linear((INK shr 8) and 0xFF),
                linear(INK and 0xFF),
            )
            val withWhite = 1.05 / (fill + 0.05)
            val withDark = (fill + 0.05) / (dark + 0.05)
            return if (withWhite >= withDark) 0xFFFFFFFF.toInt() else INK
        }

        /** A press of plus or minus, told apart per widget by its address. */
        private fun countIntent(context: Context, widgetId: Int, action: String) =
            PendingIntent.getBroadcast(
                context,
                widgetId,
                Intent(context, CounterWidget::class.java)
                    .setAction(action)
                    .setData(Uri.parse("countersink://widget/$widgetId"))
                    .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        private fun openIntent(context: Context) = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java)
                .setAction(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_LAUNCHER)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        private fun chooseIntent(context: Context, widgetId: Int) = PendingIntent.getActivity(
            context,
            widgetId,
            Intent(context, WidgetConfigActivity::class.java)
                .setData(Uri.parse("countersink://widget/$widgetId/choose"))
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        private fun newDayIntent(context: Context) = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, CounterWidget::class.java).setAction(ACTION_NEW_DAY),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        /**
         * A per-day counter starts again from zero when the counting day
         * turns over, so the widgets are redrawn then. An inexact alarm that
         * doesn't wake the phone: it needs no permission, and if the phone is
         * asleep it goes off when the phone next wakes, which is before
         * anyone can be looking.
         */
        private fun scheduleNewDay(context: Context) {
            val (_, tomorrow) = WidgetStore.today(context)
            (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .set(AlarmManager.RTC, tomorrow + 1000, newDayIntent(context))
        }
    }
}
