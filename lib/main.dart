import 'dart:async';

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/helpers/device_helper.dart';
import 'package:bachelor_flutter_crush/pages/non_mobile_page.dart';
import 'package:bachelor_flutter_crush/pages/non_standalone_page.dart';
import 'package:bachelor_flutter_crush/pages/old_version_page.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:universal_html/js.dart' as js;

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
    if (!kDebugMode) {
      if (!await DeviceHelper.isMobile()) {
        runApp(const NonMobilePage());
        return;
      }
      if (!DeviceHelper.isStandalone()) {
        runApp(const NonStandalonePage());
        return;
      }
    }
    String currentVersion = await DeviceHelper.isCurrentVersion();
    if (currentVersion != "isCurrentVersion") {
      runApp(OldVersionPage(currentVersion: currentVersion));
      return;
    }
    await FirebaseStore.init();
    js.context['handleBeforeUnload'] = js.allowInterop(handleBeforeUnload);
    js.context.callMethod('setupBeforeUnloadListener');
    runApp(const Application());
  }, (error, stackTrace) {
    FirebaseStore.sendError(error.toString(), stacktrace: stackTrace.toString());
  });
}

void handleBeforeUnload() {
  FirebaseStore.addCloseApp(DateTime.now());
}
