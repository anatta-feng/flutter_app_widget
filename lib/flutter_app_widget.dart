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

  static late final String _appGroupId;

  static void initialized({required String appGroupId}) {
    _appGroupId = appGroupId;
    _initializedIOS(appGroupId: appGroupId);
  }

  static Future<void> _initializedIOS({required String appGroupId}) async {
    await _channel.invokeMethod('initialized', <String, String>{'appGroupId': appGroupId});
  }

  static void reloadAllTimelines() async {
    await _channel.invokeMethod('reloadAllTimelines');
  }

  static dynamic getItem(String key, String appGroup) async {
    return await _channel.invokeMethod(
        'getItem', <String, String>{'key': key, 'appGroup': appGroup});
  }

  static dynamic setItem(String key, dynamic value, String appGroup) async {
    return await _channel.invokeMethod('setItem',
        <String, dynamic>{'key': key, 'value': value, 'appGroup': appGroup});
  }
}
