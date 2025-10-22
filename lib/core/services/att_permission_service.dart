import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle App Tracking Transparency permission request
/// This service ensures ATT permission is requested at app startup
class ATTPermissionService {
  static ATTPermissionService? _instance;
  static const String _attRequestedKey = 'att_permission_requested';
  static const String _attAuthorizedKey = 'att_permission_authorized';

  ATTPermissionService._internal();

  static ATTPermissionService get instance {
    _instance ??= ATTPermissionService._internal();
    return _instance!;
  }

  /// Check if ATT permission has been requested before
  Future<bool> hasRequestedPermission() async {
    if (!Platform.isIOS) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_attRequestedKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking ATT permission history: $e');
      }
      return false;
    }
  }

  /// Check if ATT permission is currently authorized
  Future<bool> isPermissionAuthorized() async {
    if (!Platform.isIOS) return true;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      final isAuthorized = status == TrackingStatus.authorized;

      // Save the authorization status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_attAuthorizedKey, isAuthorized);

      if (kDebugMode) {
        debugPrint('📱 Current ATT Status: $status');
        debugPrint('📱 Tracking authorized: $isAuthorized');
      }

      return isAuthorized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking ATT authorization: $e');
      }
      return false;
    }
  }

  /// Request ATT permission with proper timing
  Future<TrackingStatus> requestPermission() async {
    if (!Platform.isIOS) return TrackingStatus.authorized;

    try {
      // Check if we've already requested permission
      final hasRequested = await hasRequestedPermission();
      if (hasRequested) {
        if (kDebugMode) {
          debugPrint('📱 ATT permission already requested before');
        }
        return await AppTrackingTransparency.trackingAuthorizationStatus;
      }

      if (kDebugMode) {
        debugPrint('📱 Requesting ATT permission...');
      }

      // Request the permission
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();

      // Save that we've requested permission
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_attRequestedKey, true);
      await prefs.setBool(
        _attAuthorizedKey,
        status == TrackingStatus.authorized,
      );

      if (kDebugMode) {
        debugPrint('📱 ATT Permission result: $status');
      }

      return status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error requesting ATT permission: $e');
      }
      return TrackingStatus.denied;
    }
  }

  /// Reset permission state (for testing purposes)
  Future<void> resetPermissionState() async {
    if (!Platform.isIOS) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_attRequestedKey);
      await prefs.remove(_attAuthorizedKey);

      if (kDebugMode) {
        debugPrint('📱 ATT permission state reset');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resetting ATT permission state: $e');
      }
    }
  }

  /// Get permission status description
  String getPermissionStatusDescription(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.authorized:
        return 'Authorized';
      case TrackingStatus.denied:
        return 'Denied';
      case TrackingStatus.restricted:
        return 'Restricted';
      case TrackingStatus.notDetermined:
        return 'Not Determined';
      case TrackingStatus.notSupported:
        return 'Not Supported';
    }
  }
}
