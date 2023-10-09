import 'dart:async';

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:bachelor_flutter_crush/services/service_worker_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  ReportingService.init();
  ServiceWorkerNotification().serviceWorkerNotification();
  runZonedGuarded(() {
    runApp(const Application());
  }, (error, stackTrace) {
    ReportingService.sendErrorToAppwrite(error.toString(), stacktrace: stackTrace.toString());
  });
  runApp(const Application());
}
