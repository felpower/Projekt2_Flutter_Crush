import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:bachelor_flutter_crush/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helpers/audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Audio.init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  ReportingService.init();
  await LocalNotificationService().init();
  LocalNotificationService().scheduleNotification();
  return runApp(const Application());
}
