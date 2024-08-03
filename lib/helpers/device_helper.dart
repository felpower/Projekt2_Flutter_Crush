import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';
import 'package:universal_html/html.dart' as html;

class DeviceHelper {
  static final userAgent = html.window.navigator.userAgent;

  static bool isIOSWebDevice() {
    if (isIOSDevice()) {
      return !isStandalone();
    }
    return false;
  }

  static bool isIOSDevice() {
    if (userAgent.contains('iPad') || userAgent.contains('iPhone') || userAgent.contains('iPod')) {
      return true;
    }
    return false;
  }

  static bool isStandalone() {
    final isStandAlone = html.window.matchMedia('(display-mode: standalone)').matches;
    if (!isStandAlone) {
      return false;
    }
    return true;
  }

  static bool isMobile() {
    if (userAgent.contains("Mobi") ||
        userAgent.contains("Android") ||
        userAgent.contains("iPhone") ||
        userAgent.contains("iPad") ||
        userAgent.contains("iPod") ||
        userAgent.contains("Windows Phone") ||
        userAgent.contains("BlackBerry")) {
      return true;
    }
    return false;
  }

  static bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }

  static Future<String> isCurrentVersion() {
    var uuid = FirebaseStore.getUuid();
    return uuid.then((value) {
      if (value.startsWith(FirebaseStore.getCurrentVersion())) {
        return "isCurrentVersion";
      }
      return uuid;
    });
  }
}
