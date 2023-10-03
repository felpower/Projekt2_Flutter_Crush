import 'dart:html';

class ServiceWorkerNotification {
  Future<void> requestNotificationPermission() async {
    print("requestNotificationPermission");
    if (Notification.permission == "default") {
      Notification.requestPermission();
    }
  }
  void sendWebNotification(String title, String body) {
    print("sendWebNotification");

    if (Notification.permission == "granted") {
      Notification(title, body: body);
    }
  }

  void checkNotificiation(){
    print("Notification.permission: ${Notification.permission}");
  }
}
