import 'package:url_launcher/url_launcher.dart';

class UrlHelper{
  static Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
    }
  }
}