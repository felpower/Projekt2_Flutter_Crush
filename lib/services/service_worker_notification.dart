// import 'dart:html' as html;
// import 'dart:html';
// import 'dart:math';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../persistence/xp_service.dart';
//
// class ServiceWorkerNotification {
//   static const String notificationsAlreadyScheduled = 'notificationsAlreadyScheduled';
//
//   Future<void> requestNotificationPermission() async {
//     if (Notification.permission == "default") {
//       Notification.requestPermission();
//     }
//   }
//
//   void checkNotificationPermission() {
//     print("Notification.permission: ${Notification.permission}");
//     serviceWorkerNotification();
//   }
//
//   void sendNotification(var title, var body, var seconds, {var icon = 'icons/Icon-192.png'}) {
//     final sw = window.navigator.serviceWorker;
//     var timeToNotification = seconds * 1000;
//     sw?.controller?.postMessage({
//       'action': 'scheduleNotification',
//       'delay': timeToNotification,
//       'title': title,
//       'body': body,
//       'icon': icon,
//     });
//   }
//
//   void serviceWorkerNotification() {
//     if (html.window.navigator.serviceWorker != null) {
//       html.window.navigator.serviceWorker!.register('/sw.js').then((registration) {
//         print('Service Worker registered with scope: ${registration.scope}');
//
//         // Listen for updates to the service worker.
//         registration.addEventListener('updatefound', (event) {
//           print('Service Worker update found.');
//
//           html.ServiceWorker? newWorker = registration.installing;
//
//           newWorker?.on['stateChange'].listen((event) {
//             switch (newWorker.state) {
//               case 'installed':
//                 if (window.navigator.serviceWorker?.controller != null) {
//                   print('New Service Worker installed but not yet active.');
//                 } else {
//                   print('New Service Worker installed and active.');
//                 }
//                 break;
//               case 'activating':
//                 print('Service Worker activating...');
//                 break;
//               case 'activated':
//                 print('New Service Worker is now active.');
//                 break;
//               case 'redundant':
//                 print('Installing Service Worker became redundant.');
//                 break;
//               default:
//                 break;
//             }
//           });
//         });
//       }).catchError((error) {
//         print('Service Worker registration failed: $error');
//       });
//     }
//   }
//
//   void scheduleNotification() async {
//     int min = 2;
//     int max = 4;
//     if (!await _notificationsAlreadyScheduled()) {
//       int multiplier = min + Random().nextInt(max - min);
//       sendNotification(
//           'Flutter Crush', 'Tap here to get ${multiplier}x XP for the next 15 minutes!', 60 * 60,
//           icon: 'icons/Icon-192.png');
//       XpService.addMultiplier(multiplier);
//     }
//   }
//
//   Future<bool> _notificationsAlreadyScheduled() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? alreadyScheduled = prefs.getBool(notificationsAlreadyScheduled);
//     prefs.setBool(notificationsAlreadyScheduled, true);
//     if (alreadyScheduled == null) {
//       return false;
//     }
//     return true;
//   }
// }
