import 'package:url_launcher/url_launcher.dart';

class MyUrlLuncher {
  static Future<void> launchLink(String urlString) async {
    final Uri url = Uri.parse(urlString);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'could not launch $urlString';
    }
  }
}
