import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

class WebViewService {
  static WebViewController createController(VoidCallback onPageFinished) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            debugPrint("PAGE_FINISH: $url");

            if (url.contains("/Account/Login")) {
              await WebViewCookieManager().clearCookies();
              debugPrint("COOKIES CLEARED");
            }

            onPageFinished();
          },

          onNavigationRequest: (request) async {
            debugPrint("NAVIGATION: ${request.url}");

            final uri = Uri.parse(request.url);

            if (uri.scheme == 'mailto' || uri.scheme == 'tel') {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );
  }
}