import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_app_widget/flutter_app_widget.dart';

import 'flutter_widget_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String uri = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterAppWidget.initialized(appGroupId: 'group.com.toner');
    FlutterAppWidget.widgetClicked.listen((event) {
      uri = event?.toString() ?? '';
      setState(() {

      });
      print('widgetClicked: $event');
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterAppWidget.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  late final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text(
              'Enter a text 🙏🏻, launch uri: $uri',
            ),
            TextField(
              controller: textController,
            ),
            ElevatedButton(
                onPressed: () async {
                  print(jsonEncode(
                      FlutterWidgetData(true, textController.text)));
                  final result = await FlutterAppWidget.setWidgetDataAndUpdate(
                      key: 'widgetData',
                      value: jsonEncode(
                          FlutterWidgetData(true, textController.text)),
                      androidWidgetProviderClass: 'RunningWidgetProvider');
                  print('[Update Button]: $result');
                },
                child: const Text('Start')),
            ElevatedButton(
                onPressed: () async {
                  await FlutterAppWidget.removeWidgetDataAndUpdate(
                      key: 'widgetData',
                      androidWidgetProviderClass: 'RunningWidgetProvider');
                },
                child: const Text('Pause')),
          ],
        ),
      ),
    );
  }
}
