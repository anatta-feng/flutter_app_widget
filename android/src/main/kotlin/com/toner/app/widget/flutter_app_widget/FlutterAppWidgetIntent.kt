package com.toner.app.widget.flutter_app_widget

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build

object FlutterAppWidgetLaunchIntent {
    const val FLUTTER_APP_WIDGET_LAUNCH_INTENT = "com.toner.app.widget.LAUNCH"

    @SuppressLint("UnspecifiedImmutableFlag")
    fun <T> getActivity(
        context: Context,
        activityClass: Class<T>,
        uri: Uri? = null
    ): PendingIntent where T : Activity {
        val intent = Intent(context, activityClass)
        intent.data = uri
        intent.action = FLUTTER_APP_WIDGET_LAUNCH_INTENT
        val flag: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(context, 0, intent, flag)
    }
}