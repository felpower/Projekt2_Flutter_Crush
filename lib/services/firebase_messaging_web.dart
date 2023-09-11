import 'dart:math';

import 'package:bachelor_flutter_crush/persistence/xp_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FirebaseMessagingWeb {
  Future<void> init() async {
    print("INIT NOTIFICATION Firebase Web");
    tz.initializeTimeZones();
    initMobileNotifications();
    getWebToken();
  }

  static const String notificationsAlreadyScheduled = 'notificationsAlreadyScheduled';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings('tile');
  final DarwinInitializationSettings iosInitializationSettings = const DarwinInitializationSettings(
      requestSoundPermission: false, requestAlertPermission: true, requestBadgePermission: true);

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'messages', // id
    'Messages', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  void initMobileNotifications() {
    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    createChannel(channel);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void createChannel(AndroidNotificationChannel channel) async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> getWebToken() async {
    await initializeFirebase();

    getToken();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDDC-2IZHc3NCXp1lQtOauQMyZ-1Wz5RrE",
            authDomain: "flutter-crush-4ece9.firebaseapp.com",
            projectId: "flutter-crush-4ece9",
            storageBucket: "flutter-crush-4ece9.appspot.com",
            messagingSenderId: "287711278777",
            appId: "1:287711278777:web:07e4db55dcb6ef0be44d68",
            measurementId: "G-0ZT7HMRWNX"));
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
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

  NotificationDetails createNotificationDetails() {
    NotificationDetails notificationDetails = NotificationDetails(
        android: createAndroidNotificationDetails(), iOS: createIosNotificationDetails());
    return notificationDetails;
  }

  getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("DeviceToken: $token");
  }

  void showNotification(RemoteNotification? notification) {
    final android = notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? "No Title",
          notification.body ?? "No Body",
          NotificationDetails(
            android: createAndroidNotificationDetails(),
          ));
    }
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

  createAndroidNotificationDetails() {
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
    );
  }

  DarwinNotificationDetails createIosNotificationDetails() {
    const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );
    return iosNotificationDetails;
  }
}
