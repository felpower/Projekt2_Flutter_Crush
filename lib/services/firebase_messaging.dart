// ignore_for_file: avoid_print
import 'dart:async';

import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import '../helpers/device_helper.dart';

class FirebaseMessagingWeb {
  Future<void> init() async {
    await initializeFirebase();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    getToken();
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

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  static Future<String> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              "BKC1rzsuRtguEMKZrLseyxnKXMqT2vAZ0J3VK8ooClS9AUj4ujC_aRYxTnRHudJv5vIMvaCoUukDLbjAWaGSOO4");
      if (token != null) {
        FirebaseStore.currentPushToken(token);
        return token;
      } else {
        return "No token found, please reload page";
      }
    } catch (e) {
      print(e);
      return "No token found, please reload page";
    }
  }

}
