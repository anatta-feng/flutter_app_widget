import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterAppWidget {
  static const MethodChannel _channel = MethodChannel('flutter_app_widget');
  static const EventChannel _eventChannel =
      EventChannel('flutter_app_widget/events');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Stream<Uri?> get widgetClicked {
    return _eventChannel.receiveBroadcastStream().map<Uri?>((event) {
      if (event != null) {
        if (event is String) {
          try {
            return Uri.parse(event);
          } on FormatException {
            debugPrint('Received Data($event) is not parsebale into an Uri');
          }
        }
        return Uri();
      } else {
        return null;
      }
    });
  }

  static Future<void> initialized({required String appGroupId}) async {
    await _initializedIOS(appGroupId: appGroupId);
  }

  static Future<void> _initializedIOS({required String appGroupId}) async {
    await _channel.invokeMethod(
        'initialized', <String, String>{'appGroupId': appGroupId});
  }

  static Future<void> updateWidget(
      {required String androidWidgetProviderClass}) async {
    await _channel.invokeMethod('updateWidget', <String, String>{
      'androidWidgetProviderClass': androidWidgetProviderClass
    });
  }

  static dynamic setWidgetData(
      {required String key, required String value}) async {
    return await _channel.invokeMethod(
        'setWidgetData', <String, dynamic>{'key': key, 'value': value});
  }

  static dynamic setWidgetDataAndUpdate(
      {required String key,
      required String value,
      required String androidWidgetProviderClass}) async {
    final result = await setWidgetData(key: key, value: value);
    await updateWidget(androidWidgetProviderClass: androidWidgetProviderClass);
    return result;
  }

  static Future<bool> removeWidgetData({required String key}) async {
    return await _channel
        .invokeMethod('removeWidgetData', <String, String>{'key': key});
  }

  static dynamic removeWidgetDataAndUpdate(
      {required String key, required String androidWidgetProviderClass}) async {
    final result = await removeWidgetData(key: key);
    await updateWidget(androidWidgetProviderClass: androidWidgetProviderClass);
    return result;
  }
}
