import 'dart:async';

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/helpers/device_helper.dart';
import 'package:bachelor_flutter_crush/pages/non_mobile_page.dart';
import 'package:bachelor_flutter_crush/pages/non_standalone_page.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:universal_html/html.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    usePathUrlStrategy();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
    if (!await DeviceHelper.isMobile()) {
      // runApp(const NonMobilePage());
      // return;
    }
    if (!DeviceHelper.isStandalone()) {
      // runApp(const NonStandalonePage());
      // return;
    }
    await FirebaseStore.init();
    window.onBeforeUnload.listen((event) {
      FirebaseStore.addCloseApp(DateTime.now());
    });
    runApp(const Application());
  }, (error, stackTrace) {
    FirebaseStore.sendError(error.toString(), stacktrace: stackTrace.toString());
  });
}
