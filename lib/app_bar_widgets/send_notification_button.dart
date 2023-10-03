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
    print("sendNotification");
    ServiceWorkerNotification().checkNotificiation();
    final sw = window.navigator.serviceWorker;
    sw?.controller?.postMessage({
      'action': 'scheduleNotification',
      'delay': 2 * 60 * 1000, // 2 minutes in milliseconds
      'title': 'Delayed Notification Title',
      'body': 'This is the notification body',
      'icon': '/path_to_icon.png', // Optional
    });
  }
}
