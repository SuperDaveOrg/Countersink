package com.superdavelab.countersink

import android.content.ContentValues
import android.content.Context
import android.content.res.Configuration
import android.database.sqlite.SQLiteDatabase
import java.util.Calendar
import java.util.Locale
import java.util.UUID

/** A counter as a widget shows it. */
internal data class WidgetCounter(
    val id: String,
    val name: String,
    val group: String,
    val color: Int,
    val color2: Int?,
    val step: Int,
    val daily: Boolean,
    /** The number on the card: today's total for a per-day counter. */
    val value: Int,
)

/**
 * What the home-screen widgets and the quick-settings tile need from the
 * app's data, read and written
 * straight from Android so a widget works without Flutter running.
 *
 * It opens the same SQLite file the app does and keeps to the app's rules: a
 * counter has no number of its own, so a press of plus or minus is one row in
 * `events`, exactly as the app would write it; a count never goes below zero;
 * a per-day counter shows the current counting day, which begins at the hour
 * chosen in Settings.
 *
 * Calculated counters are left out altogether: their number comes from a
 * formula in the app, and they can't be counted on.
 *
 * It never creates or alters the database. Until the app has been opened
 * once there is nothing to read, and the widget says so. It reads columns by
 * name and tolerates ones that are missing, so it keeps working if it runs
 * against a database the app hasn't upgraded yet.
 */
internal object WidgetStore {
    private const val PREFS = "countersink_widgets"
    private const val COUNTED = "counted"
    private const val TILE = "tile_counter"
    private const val DATABASE = "countersink.db"

    /** Where Flutter's shared_preferences plugin keeps the app's settings. */
    private const val FLUTTER_PREFS = "FlutterSharedPreferences"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /** The counter a widget shows, or null if none has been chosen. */
    fun counterFor(context: Context, widgetId: Int): String? =
        prefs(context).getString("widget_$widgetId", null)

    fun setCounter(context: Context, widgetId: Int, counterId: String) {
        prefs(context).edit().putString("widget_$widgetId", counterId).apply()
    }

    /** The counter the quick-settings tile adds to, or null if none is chosen. */
    fun tileCounter(context: Context): String? = prefs(context).getString(TILE, null)

    fun setTileCounter(context: Context, counterId: String?) {
        val edit = prefs(context).edit()
        if (counterId == null) edit.remove(TILE) else edit.putString(TILE, counterId)
        edit.apply()
    }

    fun forget(context: Context, widgetIds: IntArray) {
        val edit = prefs(context).edit()
        for (id in widgetIds) edit.remove("widget_$id")
        edit.apply()
    }

    /**
     * Whether a widget has counted since the app last asked, which also
     * clears it. The app uses this to know its automatic backup is out of
     * date.
     */
    fun takeCounted(context: Context): Boolean {
        val counted = prefs(context).getBoolean(COUNTED, false)
        if (counted) prefs(context).edit().remove(COUNTED).apply()
        return counted
    }

    /** The hour a counting day begins, as chosen in the app's Settings. */
    private fun dayStartHour(context: Context): Int {
        val stored = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            .all["flutter.day_start_hour"]
        return ((stored as? Number)?.toInt() ?: 0).coerceIn(0, 11)
    }

    /**
     * The current counting day as the instants it covers, from the first up
     * to, not including, the second. By calendar fields, never by adding
     * hours, so it holds on the days the clocks change.
     */
    fun today(context: Context, now: Long = System.currentTimeMillis()): Pair<Long, Long> {
        val hour = dayStartHour(context)
        val start = Calendar.getInstance().apply {
            timeInMillis = now
            if (get(Calendar.HOUR_OF_DAY) < hour) add(Calendar.DAY_OF_MONTH, -1)
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val end = (start.clone() as Calendar).apply { add(Calendar.DAY_OF_MONTH, 1) }
        return start.timeInMillis to end.timeInMillis
    }

    /**
     * The same context speaking the language picked in the app's Settings,
     * if one was; otherwise the phone's.
     */
    fun localized(context: Context): Context {
        val code = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            .all["flutter.language"] as? String ?: return context
        val config = Configuration(context.resources.configuration)
        config.setLocale(Locale(code))
        return context.createConfigurationContext(config)
    }

    /** Opens the app's database, or null if the app has never made one. */
    private fun open(context: Context, writable: Boolean): SQLiteDatabase? {
        val file = context.getDatabasePath(DATABASE)
        if (!file.exists()) return null
        return try {
            SQLiteDatabase.openDatabase(
                file.path,
                null,
                if (writable) SQLiteDatabase.OPEN_READWRITE else SQLiteDatabase.OPEN_READONLY,
            )
        } catch (_: Exception) {
            null
        }
    }

    private fun SQLiteDatabase.hasColumn(table: String, column: String): Boolean =
        rawQuery("PRAGMA table_info($table)", null).use { c ->
            val name = c.getColumnIndex("name")
            while (c.moveToNext()) if (c.getString(name) == column) return true
            false
        }

    private const val SELECT =
        "SELECT c.*, g.name AS group_name FROM counters c " +
            "JOIN counter_groups g ON g.id = c.group_id"

    private fun SQLiteDatabase.counters(where: String, args: Array<String>, context: Context): List<WidgetCounter> {
        val (dayStart, dayEnd) = today(context)
        val found = mutableListOf<WidgetCounter>()
        rawQuery("$SELECT $where", args).use { c ->
            val color2 = c.getColumnIndex("color2")
            val step = c.getColumnIndex("step")
            val daily = c.getColumnIndex("daily")
            val formula = c.getColumnIndex("formula")
            while (c.moveToNext()) {
                // A counter worked out from others has no count of its own
                // to show or add to here; the app is where it is seen.
                if (formula >= 0 && !c.isNull(formula)) continue
                val id = c.getString(c.getColumnIndexOrThrow("id"))
                val perDay = daily >= 0 && c.getInt(daily) == 1
                found += WidgetCounter(
                    id = id,
                    name = c.getString(c.getColumnIndexOrThrow("name")),
                    group = c.getString(c.getColumnIndexOrThrow("group_name")),
                    color = c.getLong(c.getColumnIndexOrThrow("color")).toInt(),
                    color2 = if (color2 >= 0 && !c.isNull(color2)) c.getLong(color2).toInt() else null,
                    step = if (step >= 0) c.getInt(step).coerceAtLeast(1) else 1,
                    daily = perDay,
                    value = valueOf(id, perDay, dayStart, dayEnd),
                )
            }
        }
        return found
    }

    /** The sum of a counter's events: today's for a per-day counter. */
    private fun SQLiteDatabase.valueOf(id: String, daily: Boolean, dayStart: Long, dayEnd: Long): Int {
        val (sql, args) = if (daily) {
            "SELECT COALESCE(SUM(delta), 0) FROM events WHERE counter_id = ? AND at >= ? AND at < ?" to
                arrayOf(id, dayStart.toString(), dayEnd.toString())
        } else {
            "SELECT COALESCE(SUM(delta), 0) FROM events WHERE counter_id = ?" to arrayOf(id)
        }
        return rawQuery(sql, args).use { c -> if (c.moveToFirst()) c.getLong(0).toInt() else 0 }
    }

    /** One counter with its number, or null if it's gone. */
    fun read(context: Context, counterId: String): WidgetCounter? {
        val db = open(context, writable = false) ?: return null
        return try {
            db.counters("WHERE c.id = ?", arrayOf(counterId), context).firstOrNull()
        } catch (_: Exception) {
            null
        } finally {
            db.close()
        }
    }

    /** Every counter that isn't archived, in the order the app shows them. */
    fun list(context: Context): List<WidgetCounter> {
        val db = open(context, writable = false) ?: return emptyList()
        return try {
            val where = if (db.hasColumn("counters", "archived")) "WHERE c.archived = 0 " else ""
            db.counters(
                where + "ORDER BY g.position, g.name, c.position, c.name",
                emptyArray(),
                context,
            )
        } catch (_: Exception) {
            emptyList()
        } finally {
            db.close()
        }
    }

    /**
     * One press of plus ([direction] 1) or minus (-1) on a widget: the
     * counter's step, written as an event like any made in the app. Taking
     * away stops at zero.
     */
    fun count(context: Context, counterId: String, direction: Int) {
        val db = open(context, writable = true) ?: return
        try {
            val counter = db.counters("WHERE c.id = ?", arrayOf(counterId), context)
                .firstOrNull() ?: return
            val delta = if (direction > 0) {
                counter.step
            } else {
                -minOf(counter.step, maxOf(counter.value, 0))
            }
            if (delta == 0) return
            val event = ContentValues().apply {
                put("id", UUID.randomUUID().toString())
                put("counter_id", counterId)
                put("at", System.currentTimeMillis())
                put("delta", delta)
                put("kind", "tap")
            }
            db.insertOrThrow("events", null, event)
            prefs(context).edit().putBoolean(COUNTED, true).apply()
        } catch (_: Exception) {
            // A count that can't be written is dropped; the widget then shows
            // the number that was really saved.
        } finally {
            db.close()
        }
    }
}
