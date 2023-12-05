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

import 'services/firebase_messaging.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    usePathUrlStrategy();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (!await DeviceHelper.isMobile()) {
      // runApp(const NonMobilePage());
      // return;
    }
    if (!DeviceHelper.isStandalone()) {
      // runApp(const NonStandalonePage());
      // return;
    }
    await FirebaseMessagingWeb().init();
    FirebaseStore.init();
    window.onBeforeUnload.listen((event) {
      FirebaseStore.addCloseApp(DateTime.now());
    });
    runApp(const Application());
  }, (error, stackTrace) {
    FirebaseStore.sendError(error.toString(), stacktrace: stackTrace.toString());
  });
}
