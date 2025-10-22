import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

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
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      final isAuthorized = status == TrackingStatus.authorized;

      if (kDebugMode) {
        debugPrint('📱 ATT Status: $status');
        debugPrint('📱 Tracking authorized: $isAuthorized');
      }

      return isAuthorized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking tracking authorization: $e');
      }
      return false;
    }
  }

  /// Request tracking authorization if needed
  Future<TrackingStatus> requestTrackingAuthorization() async {
    if (!Platform.isIOS) return TrackingStatus.authorized;

    try {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();

      if (kDebugMode) {
        debugPrint('📱 ATT Permission requested. Status: $status');
      }

      return status;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error requesting tracking authorization: $e');
      }
      return TrackingStatus.denied;
    }
  }
}
