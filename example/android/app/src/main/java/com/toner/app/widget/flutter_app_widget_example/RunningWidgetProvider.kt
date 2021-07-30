package com.toner.app.widget.flutter_app_widget_example

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.SystemClock
import android.widget.RemoteViews
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import com.toner.app.widget.flutter_app_widget.FlutterAppWidgetLaunchIntent
import com.toner.app.widget.flutter_app_widget.FlutterAppWidgetProvider

/**
 * Implementation of App Widget functionality.
 */
class RunningWidgetProvider : FlutterAppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val string = widgetData.getString("widgetData", null)
            val flutterData = if (string != null) {
                Moshi.Builder()
                    .addLast(KotlinJsonAdapterFactory())
                    .build().adapter(FlutterData::class.java)
                    .fromJson(string)
            } else {
                null
            }
            updateAppWidget(context, appWidgetManager, appWidgetId, flutterData)
        }
    }
//    override fun onUpdate(
//        context: Context,
//        appWidgetManager: AppWidgetManager,
//        appWidgetIds: IntArray
//    ) {
//        // There may be multiple widgets active, so update all of them
//        for (appWidgetId in appWidgetIds) {
//            updateAppWidget(context, appWidgetManager, appWidgetId)
//        }
//    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int,
    value: FlutterData?
) {
    val widgetText = context.getString(R.string.appwidget_text)
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.running_widget)
    if (value != null) {
        views.setTextViewText(R.id.tv_task_name, value.message)

        views.setChronometer(R.id.tv_timer, SystemClock.elapsedRealtime(), null, value.start)
    } else {
        views.setTextViewText(R.id.tv_task_name, "No message")

        views.setChronometer(R.id.tv_timer, SystemClock.elapsedRealtime(), null, false)
    }

    val pendingIntent = FlutterAppWidgetLaunchIntent.getActivity(
        context,
        MainActivity::class.java,
        Uri.parse("http://baidu.com")
    )

    views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}