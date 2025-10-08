import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service to handle notification permissions with proper UI flow
class NotificationPermissionService {
  static NotificationPermissionService? _instance;

  NotificationPermissionService._internal();

  static NotificationPermissionService get instance {
    _instance ??= NotificationPermissionService._internal();
    return _instance!;
  }

  bool _hasRequestedPermission = false;
  bool _isPermissionGranted = false;

  /// Request notification permission with proper timing
  Future<bool> requestPermissionWithDelay({
    BuildContext? context,
    Duration delay = const Duration(seconds: 3),
  }) async {
    if (_hasRequestedPermission) {
      return _isPermissionGranted;
    }

    try {
      // Wait for UI to be ready
      await Future.delayed(delay);

      if (kDebugMode) {
        debugPrint('🔔 Requesting notification permission...');
      }

      // Check current permission status first
      final currentStatus = await FirebaseMessaging.instance
          .getNotificationSettings();

      if (kDebugMode) {
        debugPrint(
          '📱 Current notification status: ${currentStatus.authorizationStatus}',
        );
      }

      // If already granted, return true
      if (currentStatus.authorizationStatus == AuthorizationStatus.authorized) {
        _isPermissionGranted = true;
        _hasRequestedPermission = true;
        return true;
      }

      // If denied, don't request again
      if (currentStatus.authorizationStatus == AuthorizationStatus.denied) {
        _isPermissionGranted = false;
        _hasRequestedPermission = true;
        return false;
      }

      // Request permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: false,
      );

      _hasRequestedPermission = true;
      _isPermissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (kDebugMode) {
        debugPrint(
          '✅ Notification permission result: ${settings.authorizationStatus}',
        );
      }

      return _isPermissionGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Notification permission request failed: $e');
      }
      _hasRequestedPermission = true;
      _isPermissionGranted = false;
      return false;
    }
  }

  /// Check if permission is already granted
  Future<bool> isPermissionGranted() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking notification permission: $e');
      }
      return false;
    }
  }

  /// Show custom permission request dialog
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Bildirim İzni'),
              content: const Text(
                'Uygulamanın size bildirim gönderebilmesi için izin vermeniz gerekiyor. '
                'Bu sayede önemli güncellemeler ve hatırlatmalar alabilirsiniz.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Şimdi Değil'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('İzin Ver'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Request permission with custom dialog flow
  Future<bool> requestPermissionWithDialog(BuildContext context) async {
    try {
      // Show custom dialog first
      final shouldRequest = await showPermissionDialog(context);

      if (!shouldRequest) {
        return false;
      }

      // Request system permission
      return await requestPermissionWithDelay(
        context: context,
        delay: Duration.zero,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Permission dialog flow failed: $e');
      }
      return false;
    }
  }

  /// Reset permission state (for testing)
  void resetPermissionState() {
    _hasRequestedPermission = false;
    _isPermissionGranted = false;
  }
}
