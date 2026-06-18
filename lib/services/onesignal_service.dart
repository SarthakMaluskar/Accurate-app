import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(
      "93672d4f-cee5-4f67-afc8-fbfb7fbffe5a",
    );

    await OneSignal.Notifications.requestPermission(true);

    Future.delayed(const Duration(seconds: 10), () {
      debugPrint("TOKEN=${OneSignal.User.pushSubscription.token}");
      debugPrint("OPTEDIN=${OneSignal.User.pushSubscription.optedIn}");
      debugPrint("SUBSCRIPTION_ID=${OneSignal.User.pushSubscription.id}");
    });
  }
}