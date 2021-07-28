
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAppWidget {
  static const MethodChannel _channel = MethodChannel('flutter_app_widget');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void reloadAllTimelines() async {
    await _channel.invokeMethod('reloadAllTimelines');
  }

  static dynamic getItem(String key, String appGroup) async {
    return await _channel.invokeMethod('getItem', <String, String>{'key': key, 'appGroup': appGroup});
  }

  static dynamic setItem(String key, dynamic value, String appGroup) async {
    return await _channel.invokeMethod('setItem', <String, dynamic>{'key': key, 'value': value, 'appGroup': appGroup});
  }
}
