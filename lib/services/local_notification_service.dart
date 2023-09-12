import 'dart:math';

import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:bachelor_flutter_crush/persistence/xp_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static const String notificationsAlreadyScheduled = 'notificationsAlreadyScheduled';

  static final LocalNotificationService _localNotificationService =
      LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _localNotificationService;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    print("INIT NOTIFICATION");
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('tile');

    const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings(
        requestSoundPermission: false, requestAlertPermission: true, requestBadgePermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      return Future(() {
        ReportingService.addNotificationTap(DateTime.now(), payload as String?);
        XpService.updateMultiplierXpTime(DateTime.now().add(const Duration(minutes: 15)));
        if (payload != null) {
          XpService.updateCurrentMultiplier(int.parse(payload as String));
        }
      });
    });
  }

  Future<void> showNotification() async {
    await flutterLocalNotificationsPlugin.show(1, 'Flutter Crush',
        'Play in the next 15 Minutes to get double XP!', createNotificationDetails());
  }

  NotificationDetails createNotificationDetails() {
    NotificationDetails notificationDetails = NotificationDetails(
        android: createAndroidNotificationDetails(), iOS: createIosNotificationDetails());
    return notificationDetails;
  }

  AndroidNotificationDetails createAndroidNotificationDetails() {
    return const AndroidNotificationDetails('testChannelId', 'testChannelName');
  }

  DarwinNotificationDetails createIosNotificationDetails() {
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );
    return iosNotificationDetails;
  }

  void disableNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification() async {
    int min = 2;
    int max = 4;
    if (!await _notificationsAlreadyScheduled()) {
      for (int i = 0; i < 7; i++) {
        int multiplier = min + Random().nextInt(max - min);
        await flutterLocalNotificationsPlugin.zonedSchedule(
            i,
            'Flutter Crush',
            'Tap here to get ${multiplier}x XP for the next 15 minutes!',
            tz.TZDateTime.now(tz.local).add(Duration(days: i, hours: 1)),
            createNotificationDetails(),
            androidAllowWhileIdle: true,
            payload: multiplier.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
        XpService.addMultiplier(multiplier);
      }
    }
  }

  Future<void> scheduleHighScoreNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        Random().nextInt(10000),
        'Flutter Crush',
        'You just got passed on the HighScore, play now to pass him again!',
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
        createNotificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<bool> _notificationsAlreadyScheduled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? alreadyScheduled = prefs.getBool(notificationsAlreadyScheduled);
    prefs.setBool(notificationsAlreadyScheduled, true);
    if (alreadyScheduled == null) {
      return false;
    }
    return true;
  }
}
