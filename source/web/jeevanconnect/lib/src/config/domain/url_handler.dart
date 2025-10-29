import 'package:url_launcher/url_launcher.dart';

import '../../shared/data/process_validators.dart';

export '../data/urls.dart';

class UrlHandler {
  launch(Uri url, context, {bool inBrowser = true}) {
    ProcessValidator().checkForInternet(context, () {
      if (inBrowser) {
        _launchInBrowser(url, context);
      } else {
        _launchInWebView(url, context);
      }
    });
  }

  Future<void> _launchInWebView(Uri url, context) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInBrowser(Uri url, context) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
