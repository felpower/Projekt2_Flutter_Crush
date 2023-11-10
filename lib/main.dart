import 'dart:async';

import 'package:bachelor_flutter_crush/application.dart';
import 'package:bachelor_flutter_crush/pages/non_mobile_page.dart';
import 'package:bachelor_flutter_crush/persistence/reporting_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'services/firebase_messaging.dart';
void main() async {
  // BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  ReportingService.init();
  await FirebaseMessagingWeb().init();
  if (await checkForMobile()) {
    runZonedGuarded(() {
      runApp(const Application());
    }, (error, stackTrace) {
      ReportingService.sendErrorToAppwrite(error.toString(), stacktrace: stackTrace.toString());
    });
  }
}

Future<bool> checkForMobile() async {
  return true;//ToDo: remove return true
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var platform = (await deviceInfoPlugin.webBrowserInfo).platform!;
  if (equalsIgnoreCase(platform, "macOS") || equalsIgnoreCase(platform, "Win32")) {
    runApp(const NonMobilePage());
    return false;
  }
  return true;
}

bool equalsIgnoreCase(String? string1, String? string2) {
  return string1?.toLowerCase() == string2?.toLowerCase();
}
