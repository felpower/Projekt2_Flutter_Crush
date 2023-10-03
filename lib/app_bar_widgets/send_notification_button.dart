import 'dart:html';

import 'package:flutter/material.dart';

import '../services/ServiceWorkerNotification.dart';

class SendNotificationButton extends StatelessWidget {
  const SendNotificationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: IconButton(
          onPressed: () {
            sendNotification();
          },
          icon: const Icon(Icons.notification_add)),
    );
  }

  void sendNotification() {
    ServiceWorkerNotification().checkNotificationPermission();
    final sw = window.navigator.serviceWorker;
    var timeToNotification =  10 * 1000;
    sw?.controller?.postMessage({
      'action': 'scheduleNotification',
      'delay': timeToNotification, // 2 minutes in milliseconds
      'title': 'Delayed Notification Title',
      'body': 'This is the notification body',
      'icon': 'icons/Icon-192.png', // Optional
    });
  }
}
