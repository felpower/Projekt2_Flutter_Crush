import 'dart:html';

class ServiceWorkerNotification {
  Future<void> requestNotificationPermission() async {
    print("requestNotificationPermission");
    if (Notification.permission == "default") {
      Notification.requestPermission();
    }
  }

  void checkNotificationPermission(){
    print("Notification.permission: ${Notification.permission}");
  }
}
