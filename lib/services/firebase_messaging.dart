// ignore_for_file: avoid_print
import 'dart:async';

import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/device_helper.dart';

class FirebaseMessagingWeb {
  static Future<void> init() async {
    await initializeFirebase();
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
