import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';

/// Service to verify and log ad configuration for debugging
class AdConfigurationService {
  static AdConfigurationService? _instance;

  AdConfigurationService._internal();

  static AdConfigurationService get instance {
    _instance ??= AdConfigurationService._internal();
    return _instance!;
  }

  /// Log all ad unit configurations for verification
  void logAdConfiguration() {
    if (kDebugMode) {
      debugPrint('🔧 Ad Configuration Verification:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 Platform: ${Platform.operatingSystem}');
      debugPrint('🏷️  Application ID: ${GoogleAdsService.applicationId}');
      debugPrint('📺 Banner Ad Unit ID: ${GoogleAdsService.bannerAdUnitId}');
      debugPrint(
        '🔄 Interstitial Ad Unit ID: ${GoogleAdsService.interstitialAdUnitId}',
      );
      debugPrint(
        '🎁 Rewarded Ad Unit ID: ${GoogleAdsService.rewardedAdUnitId}',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Verify iOS configuration matches AdMob dashboard
      if (Platform.isIOS) {
        _verifyIOSConfiguration();
      }
    }
  }

  /// Verify iOS configuration matches AdMob dashboard
  void _verifyIOSConfiguration() {
    debugPrint('🍎 iOS Configuration Verification:');

    // Expected values from AdMob dashboard
    const expectedAppId = 'ca-app-pub-3499593115543692~7549075426';
    const expectedBannerId = 'ca-app-pub-3499593115543692/3363871102';
    const expectedInterstitialId = 'ca-app-pub-3499593115543692/8013508657';
    const expectedRewardedId = 'ca-app-pub-3499593115543692/3125989969';

    final actualAppId = GoogleAdsService.applicationId;
    final actualBannerId = GoogleAdsService.bannerAdUnitId;
    final actualInterstitialId = GoogleAdsService.interstitialAdUnitId;
    final actualRewardedId = GoogleAdsService.rewardedAdUnitId;

    // Verify each ID
    _verifyId('Application ID', expectedAppId, actualAppId);
    _verifyId('Banner Ad Unit ID', expectedBannerId, actualBannerId);
    _verifyId(
      'Interstitial Ad Unit ID',
      expectedInterstitialId,
      actualInterstitialId,
    );
    _verifyId('Rewarded Ad Unit ID', expectedRewardedId, actualRewardedId);
  }

  /// Verify individual ad unit ID
  void _verifyId(String name, String expected, String actual) {
    if (expected == actual) {
      debugPrint('✅ $name: CORRECT');
    } else {
      debugPrint('❌ $name: MISMATCH');
      debugPrint('   Expected: $expected');
      debugPrint('   Actual:   $actual');
    }
  }

  /// Check if all required ad units are configured
  bool areAllAdUnitsConfigured() {
    try {
      final appId = GoogleAdsService.applicationId;
      final bannerId = GoogleAdsService.bannerAdUnitId;
      final interstitialId = GoogleAdsService.interstitialAdUnitId;
      final rewardedId = GoogleAdsService.rewardedAdUnitId;

      return appId.isNotEmpty &&
          bannerId.isNotEmpty &&
          interstitialId.isNotEmpty &&
          rewardedId.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking ad unit configuration: $e');
      return false;
    }
  }

  /// Get configuration summary for debugging
  Map<String, String> getConfigurationSummary() {
    return {
      'platform': Platform.operatingSystem,
      'applicationId': GoogleAdsService.applicationId,
      'bannerAdUnitId': GoogleAdsService.bannerAdUnitId,
      'interstitialAdUnitId': GoogleAdsService.interstitialAdUnitId,
      'rewardedAdUnitId': GoogleAdsService.rewardedAdUnitId,
    };
  }
}
