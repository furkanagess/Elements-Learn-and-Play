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
      debugPrint('🌍 Environment: ${GoogleAdsService.environmentName}');
      debugPrint('📱 Platform: ${GoogleAdsService.platformName}');
      debugPrint('🧪 Using Test Ads: ${GoogleAdsService.isUsingTestAds}');
      debugPrint('🏷️  Application ID: ${GoogleAdsService.applicationId}');
      debugPrint('📺 Banner Ad Unit ID: ${GoogleAdsService.bannerAdUnitId}');
      debugPrint(
        '🔄 Interstitial Ad Unit ID: ${GoogleAdsService.interstitialAdUnitId}',
      );
      debugPrint(
        '🎁 Rewarded Ad Unit ID: ${GoogleAdsService.rewardedAdUnitId}',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Verify configuration
      _verifyConfiguration();
    }
  }

  /// Verify configuration matches expected values
  void _verifyConfiguration() {
    debugPrint('🔍 Configuration Verification:');

    // Validate configuration
    final isValid = GoogleAdsService.validateConfiguration();

    if (isValid) {
      debugPrint('✅ Configuration validation: PASSED');
    } else {
      debugPrint('❌ Configuration validation: FAILED');
    }

    // Platform-specific verification
    if (Platform.isIOS) {
      _verifyIOSConfiguration();
    } else if (Platform.isAndroid) {
      _verifyAndroidConfiguration();
    }
  }

  /// Verify iOS configuration matches AdMob dashboard
  void _verifyIOSConfiguration() {
    debugPrint('🍎 iOS Configuration Verification:');

    // Expected values from AdMob dashboard (production)
    const expectedAppId = 'ca-app-pub-3499593115543692~7549075426';
    const expectedBannerId = 'ca-app-pub-3499593115543692/3363871102';
    const expectedInterstitialId = 'ca-app-pub-3499593115543692/8013508657';
    const expectedRewardedId = 'ca-app-pub-3499593115543692/3125989969';

    final actualAppId = GoogleAdsService.applicationId;
    final actualBannerId = GoogleAdsService.bannerAdUnitId;
    final actualInterstitialId = GoogleAdsService.interstitialAdUnitId;
    final actualRewardedId = GoogleAdsService.rewardedAdUnitId;

    // Only verify production IDs (skip test IDs)
    if (!GoogleAdsService.isUsingTestAds) {
      _verifyId('Application ID', expectedAppId, actualAppId);
      _verifyId('Banner Ad Unit ID', expectedBannerId, actualBannerId);
      _verifyId(
        'Interstitial Ad Unit ID',
        expectedInterstitialId,
        actualInterstitialId,
      );
      _verifyId('Rewarded Ad Unit ID', expectedRewardedId, actualRewardedId);
    } else {
      debugPrint('🧪 Using test ad IDs (development mode)');
    }
  }

  /// Verify Android configuration matches AdMob dashboard
  void _verifyAndroidConfiguration() {
    debugPrint('🤖 Android Configuration Verification:');

    // Expected values from AdMob dashboard (production)
    const expectedAppId = 'ca-app-pub-3499593115543692~1498506854';
    const expectedBannerId = 'ca-app-pub-3499593115543692/7394614482';
    const expectedInterstitialId = 'ca-app-pub-3499593115543692/7181453654';
    const expectedRewardedId = 'ca-app-pub-3499593115543692/5817895627';

    final actualAppId = GoogleAdsService.applicationId;
    final actualBannerId = GoogleAdsService.bannerAdUnitId;
    final actualInterstitialId = GoogleAdsService.interstitialAdUnitId;
    final actualRewardedId = GoogleAdsService.rewardedAdUnitId;

    // Only verify production IDs (skip test IDs)
    if (!GoogleAdsService.isUsingTestAds) {
      _verifyId('Application ID', expectedAppId, actualAppId);
      _verifyId('Banner Ad Unit ID', expectedBannerId, actualBannerId);
      _verifyId(
        'Interstitial Ad Unit ID',
        expectedInterstitialId,
        actualInterstitialId,
      );
      _verifyId('Rewarded Ad Unit ID', expectedRewardedId, actualRewardedId);
    } else {
      debugPrint('🧪 Using test ad IDs (development mode)');
    }
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
  Map<String, dynamic> getConfigurationSummary() {
    return GoogleAdsService.getConfigurationSummary();
  }
}
