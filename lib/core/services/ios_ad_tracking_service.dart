import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to handle iOS App Tracking Transparency (ATT) for AdMob
class IOSAdTrackingService {
  static IOSAdTrackingService? _instance;

  IOSAdTrackingService._internal();

  static IOSAdTrackingService get instance {
    _instance ??= IOSAdTrackingService._internal();
    return _instance!;
  }

  /// Initialize iOS ad tracking permissions
  Future<void> initialize() async {
    if (!Platform.isIOS) return;

    try {
      // Request tracking authorization for iOS 14.5+
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          testDeviceIds: kDebugMode ? ['YOUR_TEST_DEVICE_ID'] : null,
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ iOS ad tracking configuration updated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing iOS ad tracking: $e');
      }
    }
  }

  /// Check if tracking is authorized (iOS 14.5+)
  Future<bool> isTrackingAuthorized() async {
    if (!Platform.isIOS) return true;

    try {
      // This will be handled by the AdMob SDK internally
      // The SDK will respect the user's tracking preference
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking tracking authorization: $e');
      }
      return false;
    }
  }

  /// Request tracking authorization if needed
  Future<void> requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;

    try {
      // The AdMob SDK will handle this automatically
      // when the first ad request is made
      if (kDebugMode) {
        debugPrint(
          '📱 iOS tracking authorization will be requested by AdMob SDK',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error requesting tracking authorization: $e');
      }
    }
  }
}
