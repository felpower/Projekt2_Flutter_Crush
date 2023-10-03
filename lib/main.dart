import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:bachelor_flutter_crush/services/firebase_messaging_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'dart:js' as js;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  ReportingService.init();
  // await FirebaseMessagingWeb().init();
  // FirebaseMessagingWeb().scheduleNotification();
  // LocalNotificationService().scheduleNotification();
  runApp(const Application());

}
