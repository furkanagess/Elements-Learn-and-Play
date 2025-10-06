import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to debug and monitor iOS ad performance
class IOSAdDebugService {
  static IOSAdDebugService? _instance;

  IOSAdDebugService._internal();

  static IOSAdDebugService get instance {
    _instance ??= IOSAdDebugService._internal();
    return _instance!;
  }

  /// Log detailed ad request information for iOS
  void logAdRequest(String adType, String adUnitId) {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('📱 iOS Ad Request - Type: $adType, Unit ID: $adUnitId');
      debugPrint('📱 iOS Version: ${Platform.operatingSystemVersion}');
      debugPrint('📱 Device Info: ${Platform.operatingSystem}');
    }
  }

  /// Log ad load success
  void logAdLoadSuccess(String adType) {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('✅ iOS $adType ad loaded successfully');
    }
  }

  /// Log ad load failure with detailed error info
  void logAdLoadFailure(String adType, LoadAdError error) {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('❌ iOS $adType ad failed to load:');
      debugPrint('   Error Code: ${error.code}');
      debugPrint('   Error Domain: ${error.domain}');
      debugPrint('   Error Message: ${error.message}');
      debugPrint('   Response Info: ${error.responseInfo}');
    }
  }

  /// Log ad show success
  void logAdShowSuccess(String adType) {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('📺 iOS $adType ad shown successfully');
    }
  }

  /// Log ad show failure
  void logAdShowFailure(String adType, AdError error) {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('❌ iOS $adType ad failed to show:');
      debugPrint('   Error Code: ${error.code}');
      debugPrint('   Error Domain: ${error.domain}');
      debugPrint('   Error Message: ${error.message}');
    }
  }

  /// Check if device is in test mode
  bool isTestDevice() {
    return kDebugMode;
  }

  /// Get test device ID for iOS
  String? getTestDeviceId() {
    if (!Platform.isIOS || !kDebugMode) return null;

    // You can add your specific test device ID here
    // To get your device ID, check the console logs when running the app
    return null; // Replace with your actual test device ID if needed
  }

  /// Log AdMob SDK initialization status
  void logSDKInitialization() {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('📱 iOS AdMob SDK initialization status:');
      debugPrint('   Platform: ${Platform.operatingSystem}');
      debugPrint('   Version: ${Platform.operatingSystemVersion}');
      debugPrint('   Test Mode: ${isTestDevice()}');
    }
  }

  /// Log network connectivity status (helpful for ad loading issues)
  void logNetworkStatus() {
    if (!Platform.isIOS) return;

    if (kDebugMode) {
      debugPrint('🌐 iOS Network Status:');
      debugPrint('   Platform: ${Platform.operatingSystem}');
      debugPrint('   Check network connectivity if ads are not loading');
    }
  }
}
