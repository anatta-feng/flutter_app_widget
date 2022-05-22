package com.toner.app.widget.flutter_app_widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.*
import android.util.Log
import androidx.annotation.NonNull
import com.toner.app.widget.flutter_app_widget.FlutterAppWidgetLaunchIntent.FLUTTER_APP_WIDGET_LAUNCH_INTENT
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.*

private const val TAG = "FlutterAppWidgetPlugin"

/** FlutterAppWidgetPlugin */
class FlutterAppWidgetPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler,
    ActivityAware, PluginRegistry.NewIntentListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private lateinit var context: Context

    private var eventSink: EventChannel.EventSink? = null

    /// 等待处理的启动 intent，用于冷启动时 eventChannel 还没有建立起来时暂存
    private var pendingLaunchIntent: Intent? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_app_widget")
        channel.setMethodCallHandler(this)

        eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "flutter_app_widget/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "initialized" -> {
                initialized(result)
            }
            "updateWidget" -> {
                updateWidget(call, result)
            }
            "setWidgetData" -> {
                setWidgetData(call, result)
            }
            "removeWidgetData" -> {
                removeWidgetData(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun updateWidget(
        call: MethodCall,
        result: Result
    ) {
        if (call.hasArgument("androidWidgetProviderClass")) {
            val className = call.argument<String>("androidWidgetProviderClass")

            try {
                val javaClass = Class.forName("${context.packageName}.${className}")
                val intent = Intent(context, javaClass)
                intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                val appWidgetIds = AppWidgetManager.getInstance(context)
                    .getAppWidgetIds(ComponentName(context, javaClass))
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                context.sendBroadcast(intent)
                result.success(true)
            } catch (e: ClassNotFoundException) {
                result.error(
                    "-4",
                    "No Widget found with Name [${context.packageName}.${className}]. Argument 'androidWidgetProviderClass' must be the same as your AppWidgetProvider you wish to update",
                    e
                )
            }
        } else {
            result.error(
                "-5",
                "InvalidArguments updateWidget must be called with androidWidgetProviderClass",
                IllegalArgumentException()
            )
        }
    }

    private fun removeWidgetData(
        call: MethodCall,
        result: Result
    ) {
        if (call.hasArgument("key")) {
            val key = call.argument<String>("key")
            val prefs =
                context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).edit()
            prefs.remove(key)
            result.success(prefs.commit())
        } else {
            result.error(
                "-3",
                "InvalidArguments removeWidgetData must be called with key",
                IllegalArgumentException()
            )
        }
    }

    private fun setWidgetData(
        call: MethodCall,
        result: Result
    ) {
        if (call.hasArgument("key") && call.hasArgument("value")) {
            val key = call.argument<String>("key")
            val value = call.argument<String>("value")
            val prefs =
                context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).edit()
            if (value != null) {
                prefs.putString(key, value)
            } else {
                prefs.remove(key)
            }
            result.success(prefs.commit())
        } else {
            result.error(
                "-2",
                "InvalidArguments saveWidgetData must be called with key and value",
                IllegalArgumentException()
            )
        }
    }

    private fun initialized(result: Result) {
        result.success(true)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val PREFERENCES = "flutter_app_widget"

        fun getData(context: Context): SharedPreferences {
            return context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen: ")
        eventSink = events
        pendingLaunchIntent?.let {
            onAppLaunch(it)
        }
    }

    private fun onAppLaunch(intent: Intent) {
        if (eventSink != null) {
            if (intent.action.equals(FLUTTER_APP_WIDGET_LAUNCH_INTENT)) {
                Log.d(TAG, "onAppLaunch: $eventSink ${intent.action}")
                eventSink!!.success(intent.data?.toString() ?: true)
            }
        } else {
            pendingLaunchIntent = intent
        }

    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel: ")
        eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity: ${binding.activity.intent.action} $eventSink")
        binding.addOnNewIntentListener(this)
        onAppLaunch(binding.activity.intent)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges: ")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(
            TAG,
            "onReattachedToActivityForConfigChanges: ${binding.activity.intent.action} $eventSink"
        )
        binding.addOnNewIntentListener(this)
        onAppLaunch(binding.activity.intent)
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity: ")
    }

    override fun onNewIntent(intent: Intent): Boolean {
        Log.d(TAG, "onNewIntent: ")
        onAppLaunch(intent)
        return eventSink != null
    }

}
