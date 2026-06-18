import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../pages/no_internet_page.dart';
import '../services/connectivity_service.dart';
import '../services/webview_service.dart';
import '../widgets/splash_screen.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool showSplash = true;
  bool hasError = false;
  bool isCheckingConnection = true;

  static const String websiteUrl = 'https://erp.arthaenterprise.com/';

  @override
  void initState() {
    super.initState();

    controller = WebViewService.createController(() {
      if (mounted) {
        setState(() {
          showSplash = false;
        });
      }
    });

    checkConnection();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (results) async {
        final noInternet = results.contains(ConnectivityResult.none);

        if (!mounted) return;

        if (noInternet) {
          setState(() {
            hasError = true;
          });
        } else {
          setState(() {
            hasError = false;
          });

          final currentUrl = await controller.currentUrl();

          if (currentUrl == null || currentUrl.isEmpty) {
            await controller.loadRequest(Uri.parse(websiteUrl));
          } else {
            await controller.reload();
          }
        }
      },
    );
  }

  Future<void> checkConnection() async {
  final hasInternet = await ConnectivityService.hasInternet();

  if (!mounted) return;

  setState(() {
    isCheckingConnection = false;
    hasError = !hasInternet;
  });

  if (hasInternet) {
    await controller.clearCache();
    await WebViewCookieManager().clearCookies();

    await controller.loadRequest(
      Uri.parse(websiteUrl),
    );
  }
}

  Future<void> retryLoading() async {
    final hasInternet = await ConnectivityService.hasInternet();

    if (!mounted) return;

    if (!hasInternet) {
      setState(() {
        hasError = true;
      });
      return;
    }

    setState(() {
      hasError = false;
      showSplash = true;
    });

    await controller.loadRequest(Uri.parse(websiteUrl));
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (hasError) {
          SystemNavigator.pop();
          return;
        }

        if (await controller.canGoBack()) {
          await controller.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (isCheckingConnection)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                WebViewWidget(controller: controller),

              if (hasError)
                NoInternetPage(
                  onRefresh: retryLoading,
                ),

              if (showSplash && !hasError)
                const SplashScreen(),
            ],
          ),
        ),
      ),
    );
  }
}