import 'dart:async';

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/helpers/device_helper.dart';
import 'package:bachelor_flutter_crush/pages/non_mobile_page.dart';
import 'package:bachelor_flutter_crush/pages/non_standalone_page.dart';
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
    if (!await checkForMobile()) {
      runApp(const NonMobilePage());
      return;
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
    FirebaseStore.sendError(error.toString(),
        stacktrace: stackTrace.toString());
  });
}

Future<bool> checkForMobile() async {
  return true; //ToDo: remove return true
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var platform = (await deviceInfoPlugin.webBrowserInfo).platform!;
  print(platform);
  if (equalsIgnoreCase(platform, "macOS") ||
      equalsIgnoreCase(platform, "Win32")) {
    return false;
  }
  return true;
}

bool equalsIgnoreCase(String? string1, String? string2) {
  return string1?.toLowerCase() == string2?.toLowerCase();
}
