package com.superdavelab.countersink

import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * A tile in the phone's quick settings that adds to one counter, chosen in
 * the app's Settings: a count from anywhere, without opening the app.
 *
 * The tile carries the counter's name and its number, and a press adds the
 * counter's step, written as an event like any other ([WidgetStore]). Android
 * asks the tile what to show each time the quick settings open, so it is
 * never out of date and nothing runs in between.
 *
 * It needs no permission of the app's own. The BIND_QUICK_SETTINGS_TILE in
 * the manifest is the reverse: it lets only Android itself talk to this.
 */
class CounterTileService : TileService() {
    override fun onStartListening() = refresh()

    override fun onClick() {
        val counter = WidgetStore.tileCounter(this)?.let { WidgetStore.read(this, it) }
        if (counter == null) {
            // Nothing to count on: the app is where one is chosen.
            openApp()
            return
        }
        WidgetStore.count(this, counter.id, 1)
        refresh()
        // A widget showing the same counter moves with it.
        CounterWidget.updateAll(this)
    }

    private fun refresh() {
        val tile = qsTile ?: return
        val words = WidgetStore.localized(this)
        val counter = WidgetStore.tileCounter(this)?.let { WidgetStore.read(this, it) }
        if (counter == null) {
            tile.state = Tile.STATE_INACTIVE
            tile.label = words.getString(R.string.widget_name)
            if (Build.VERSION.SDK_INT >= 29) {
                tile.subtitle = words.getString(R.string.tile_none)
            }
            tile.contentDescription = words.getString(R.string.tile_none)
        } else {
            tile.state = Tile.STATE_ACTIVE
            // Before Android 10 a tile has one line, so the number shares it.
            if (Build.VERSION.SDK_INT >= 29) {
                tile.label = counter.name
                tile.subtitle = counter.value.toString()
            } else {
                tile.label = "${counter.name}: ${counter.value}"
            }
            tile.contentDescription =
                words.getString(R.string.widget_add, counter.step, counter.name)
        }
        tile.updateTile()
    }

    private fun openApp() {
        val intent = Intent(this, MainActivity::class.java)
            .setAction(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= 34) {
            startActivityAndCollapse(
                PendingIntent.getActivity(
                    this,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
        } else {
            @Suppress("DEPRECATION", "StartActivityAndCollapseDeprecated")
            startActivityAndCollapse(intent)
        }
    }

    companion object {
        /** Has Android ask the tile again what it shows, after the choice changes. */
        fun refresh(context: Context) {
            requestListeningState(context, ComponentName(context, CounterTileService::class.java))
        }
    }
}
