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
            ServiceWorkerNotification().sendNotification(
                "Test Notification", "This is the body of the test Notification", 10);
          },
          icon: const Icon(Icons.notification_add)),
    );
  }
}
