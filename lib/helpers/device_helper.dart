import 'package:universal_html/html.dart' as html;
import 'package:bachelor_flutter_crush/persistence/firebase_store.dart';

class DeviceHelper {
  static final userAgent = html.window.navigator.userAgent;

  static bool isIOSWebDevice() {
    if (isIOSDevice()) {
      return !isStandalone();
    }
    return false;
  }

  static bool isIOSDevice() {
    if (userAgent.contains('iPad') ||
        userAgent.contains('iPhone') ||
        userAgent.contains('iPod')) {
      return true;
    }
    return false;
  }

  static bool isStandalone() {
    final isStandAlone =
        html.window.matchMedia('(display-mode: standalone)').matches;
    if (!isStandAlone) {
      FirebaseStore.sendUserAgent(userAgent, isStandAlone);
      return false;
    }
    return true;
  }
}
