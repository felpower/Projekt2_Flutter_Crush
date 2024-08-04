// ignore_for_file: avoid_print

import 'dart:async';

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/helpers/device_helper.dart';
// import 'package:bachelor_flutter_crush/pages/non_mobile_page.dart';
import 'package:bachelor_flutter_crush/pages/non_standalone_page.dart';
import 'package:bachelor_flutter_crush/pages/old_version_page.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:bachelor_flutter_crush/services/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    usePathUrlStrategy();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      FirebaseStore.sendError("FlutterOnErrorMain",
          stacktrace: details.exceptionAsString(), extraInfo: details.toString());
    };
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
    await FirebaseStore.init();
    // if (!DeviceHelper.isMobile()) {
    //   runApp(const NonMobilePage());
    //   return;
    // }
    if (!DeviceHelper.isStandalone()) {
      PWAInstall().setup(installCallback: () {
        debugPrint('APP INSTALLED!');
      });
      runApp(const NonStandalonePage());
      return;
    }
    Uri currentUrl = Uri.parse(html.window.location.href);
    if (currentUrl.queryParameters['source'] == 'notification') {
      FirebaseStore.addNotificationTap(DateTime.now());
      startFromNotification();
      // Remove the 'source' query parameter from the URL
      Uri newUrl = currentUrl.replace(queryParameters: {});
      html.window.history.replaceState(null, 'title', newUrl.toString());
    }

    String currentVersion = await DeviceHelper.isCurrentVersion();
    if (currentVersion != "isCurrentVersion") {
      runApp(OldVersionPage(currentVersion: currentVersion));
      return;
    }
    js.context['handleBeforeUnload'] = js.allowInterop(handleBeforeUnload);
    js.context.callMethod('setupBeforeUnloadListener');
    FirebaseMessagingWeb.init();
    runApp(const Application());
  }, (error, stackTrace) {
    print('Caught error: $error');
    print('Stacktrace: $stackTrace');
    FirebaseStore.sendError(error.toString(), stacktrace: stackTrace.toString());
  });
}

Future<void> startFromNotification() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool('fromNotification', true);
}

void handleBeforeUnload() {
  FirebaseStore.addCloseApp(DateTime.now());
}
