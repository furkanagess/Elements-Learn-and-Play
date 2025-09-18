import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  FcmTokenService._();

  static final FcmTokenService instance = FcmTokenService._();

  bool _requestedPermissions = false;

  Future<void> logFcmTokenIfAvailable() async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        return;
      }

      // iOS notification permissions (no-op on Android)
      if (!_requestedPermissions && Platform.isIOS) {
        _requestedPermissions = true;
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      final String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Print in a recognisable format for logcat/console grep
        // ignore: avoid_print
        print('FCM_TOKEN: $token');
      } else {
        // ignore: avoid_print
        print('FCM_TOKEN: null');
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('FCM_TOKEN_ERROR: $e\n$st');
    }
  }
}
