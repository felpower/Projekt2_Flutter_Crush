// ignore_for_file: avoid_print
import 'dart:async';

import 'package:bachelor_flutter_crush/bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../helpers/device_helper.dart';

class FirebaseMessagingWeb {
  Future<void> init() async {
    await initializeFirebase();
    initMobileNotifications();
    setupInteractedMessage();
    getToken();
  }

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

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      addNotificationTapToDB(initialMessage);
    }
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(addNotificationTapToDB);
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    showFlutterNotification(message);
    print('Handling a background message ${message.messageId}');
  }

  void showFlutterNotification(RemoteMessage message) {
    print("showFlutterNotification");
    RemoteNotification? notification = message.notification;
    // AndroidNotification? android = message.notification?.android;
    addNotificationTapToDB(message);
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
        ),
      ),
    );
  }

  static Future<void> initializeFirebase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if (DeviceHelper.isIOSWebDevice()) {
      return;
    }
    messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    NotificationSettings settings = await messaging.getNotificationSettings();
    prefs.setString("notificationSettings", settings.authorizationStatus.toString());
    FirebaseStore.grantPushPermission(
        settings.authorizationStatus == AuthorizationStatus.authorized ? true : false);
  }

  void addNotificationTapToDB(RemoteMessage message) {
    FirebaseStore.addNotificationTap(DateTime.now());
  }

  static Future<String> getToken() async {
    try {String? token = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BKC1rzsuRtguEMKZrLseyxnKXMqT2vAZ0J3VK8ooClS9AUj4ujC_aRYxTnRHudJv5vIMvaCoUukDLbjAWaGSOO4");
    if (token != null) {
      FirebaseStore.currentPushToken(token);
      return token;
    } else {
      return "No token found, please reload page";
    }} catch(e) {
      print(e);
      return "No token found, please reload page";
    }
  }

  static void requestPermission() async {
    await FirebaseMessagingWeb().init();
    var request = Permission.notification.request();
    await html.window.navigator.permissions!.query({"name": "push", "userVisibleOnly": true});
    if (!await request.isGranted) {
      Permission.notification.request();
    }
  }
}
