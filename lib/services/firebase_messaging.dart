import 'dart:async';

import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class FirebaseMessagingWeb {
  Future<void> init() async {
    print("INIT NOTIFICATION Firebase Web");
    initMobileNotifications();
    getWebToken();
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

  static Future<void> getWebToken() async {
    await initializeFirebase();
    getToken();
  }

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    showFlutterNotification(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
  }

  void showFlutterNotification(RemoteMessage message) {
    print("showFlutterNotification");
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification!.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
        ),
      ),
    );
  }

  static Future<void> initializeFirebase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCcBYFUJbTyRWUjy6dhLbLLEj_lwhqnsh4",
            authDomain: "darkpatterns-ac762.firebaseapp.com",
            databaseURL:
                "https://darkpatterns-ac762-default-rtdb.europe-west1.firebasedatabase.app",
            projectId: "darkpatterns-ac762",
            storageBucket: "darkpatterns-ac762.appspot.com",
            messagingSenderId: "552263184384",
            appId: "1:552263184384:web:87e17944dc571dc4e028e5"));
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    prefs.setString("notificationSettings", settings.authorizationStatus.toString());
    FirebaseStore.grantPushPermission(
        settings.authorizationStatus == AuthorizationStatus.authorized ? true : false);
  }

  static Future<String> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      FirebaseStore.currentPushToken(token);
      return token;
    } else {
      return "No token found, please reload page";
    }
  }

  void showNotification(RemoteNotification? notification) {
    final android = notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? "No Title",
          notification.body ?? "No Body",
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ));
    }
  }

  static void requestPermission() async {
    print("requestPermission");
    html.PermissionStatus permission =
        await html.window.navigator.permissions!.query({"name": "push", "userVisibleOnly": true});

    print(permission.state);
    if (permission.state != "granted") {
      print("Permission not granted");
      Permission.notification.request();
    }
  }
}
