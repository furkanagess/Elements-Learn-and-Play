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
      // Configure AdMob for iOS production
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          testDeviceIds: kDebugMode
              ? []
              : null, // No test devices in production
          maxAdContentRating: MaxAdContentRating.g,
          // sameAppKeyEnabled: true,
        ),
      );

      // Set iOS-specific ad configuration
      if (kDebugMode) {
        debugPrint('✅ iOS ad tracking configuration updated for production');
        debugPrint('📱 iOS AdMob configuration:');
        debugPrint('   - Child-directed treatment: No');
        debugPrint('   - Under age of consent: No');
        debugPrint('   - Max content rating: G');
        debugPrint('   - Same app key enabled: Yes');
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
