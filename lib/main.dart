import 'dart:html' as html;

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  ReportingService.init();
  // await FirebaseMessagingWeb().init();
  // FirebaseMessagingWeb().scheduleNotification();
  // LocalNotificationService().scheduleNotification();
  runApp(const Application());
  if (html.window.navigator.serviceWorker != null) {
    html.window.navigator.serviceWorker!.register('/sw.js').then((registration) {
      print('Service Worker registered with scope: ${registration.scope}');
    }).catchError((error) {
      print('Service Worker registration failed: $error');
    });
  }
}
