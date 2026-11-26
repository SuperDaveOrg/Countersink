package com.superdavelab.countersink

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ImageView
import android.widget.ListView
import android.widget.TextView

/**
 * The list a new widget's counter is chosen from. The home screen opens it
 * when a widget is added from its own widget list, and again if the widget
 * is asked to change counter; a widget whose counter was deleted opens it
 * when touched.
 */
class WidgetConfigActivity : Activity() {
    /** In the language picked in the app's Settings, if one was. */
    override fun attachBaseContext(base: Context) =
        super.attachBaseContext(WidgetStore.localized(base))

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val widgetId = intent?.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID,
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID
        // Backing out leaves the home screen without the widget.
        val answer = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        setResult(RESULT_CANCELED, answer)
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        title = getString(R.string.widget_choose)
        setContentView(R.layout.widget_config)
        val counters = WidgetStore.list(this)
        val list = findViewById<ListView>(R.id.widget_config_list)
        val none = findViewById<TextView>(R.id.widget_config_none)
        if (counters.isEmpty()) {
            list.visibility = View.GONE
            none.visibility = View.VISIBLE
            return
        }

        list.adapter = object : BaseAdapter() {
            override fun getCount() = counters.size
            override fun getItem(position: Int) = counters[position]
            override fun getItemId(position: Int) = position.toLong()
            override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
                val row = convertView
                    ?: layoutInflater.inflate(R.layout.widget_config_row, parent, false)
                val counter = counters[position]
                row.findViewById<ImageView>(R.id.widget_config_color).setColorFilter(counter.color)
                row.findViewById<TextView>(R.id.widget_config_name).text = counter.name
                row.findViewById<TextView>(R.id.widget_config_group).text = counter.group
                return row
            }
        }
        list.setOnItemClickListener { _, _, position, _ ->
            WidgetStore.setCounter(this, widgetId, counters[position].id)
            CounterWidget.updateAll(this)
            setResult(RESULT_OK, answer)
            finish()
        }
    }
}
