import 'package:device_info_plus/device_info_plus.dart';
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

  static Future<bool> isMobile() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var platform = (await deviceInfoPlugin.webBrowserInfo).platform!;
    if (equalsIgnoreCase(platform, "macOS") ||
        equalsIgnoreCase(platform, "Win32") ||
        equalsIgnoreCase(platform, "Win32") ||
        equalsIgnoreCase(platform, "Linux") ||
        equalsIgnoreCase(platform, "X11") ||
        equalsIgnoreCase(platform, "CrOS")) {
      return false;
    }
    return true;
  }

  static bool equalsIgnoreCase(String? string1, String? string2) {
    return string1?.toLowerCase() == string2?.toLowerCase();
  }
}
