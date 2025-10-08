import 'dart:io';
import 'package:flutter/foundation.dart';

/// Environment configuration for managing sensitive data like ad IDs
class EnvironmentConfig {
  static EnvironmentConfig? _instance;

  EnvironmentConfig._internal();

  static EnvironmentConfig get instance {
    _instance ??= EnvironmentConfig._internal();
    return _instance!;
  }

  // AdMob Application IDs - Load from environment variables
  static String get _androidAppId =>
      Platform.environment['ADMOB_ANDROID_APP_ID'] ?? _getDefaultAndroidAppId();

  static String get _iosAppId =>
      Platform.environment['ADMOB_IOS_APP_ID'] ?? _getDefaultIOSAppId();

  // AdMob Ad Unit IDs - Load from environment variables
  static String get _androidBannerId =>
      Platform.environment['ADMOB_ANDROID_BANNER_ID'] ??
      _getDefaultAndroidBannerId();

  static String get _iosBannerId =>
      Platform.environment['ADMOB_IOS_BANNER_ID'] ?? _getDefaultIOSBannerId();

  static String get _androidInterstitialId =>
      Platform.environment['ADMOB_ANDROID_INTERSTITIAL_ID'] ??
      _getDefaultAndroidInterstitialId();

  static String get _iosInterstitialId =>
      Platform.environment['ADMOB_IOS_INTERSTITIAL_ID'] ??
      _getDefaultIOSInterstitialId();

  static String get _androidRewardedId =>
      Platform.environment['ADMOB_ANDROID_REWARDED_ID'] ??
      _getDefaultAndroidRewardedId();

  static String get _iosRewardedId =>
      Platform.environment['ADMOB_IOS_REWARDED_ID'] ??
      _getDefaultIOSRewardedId();

  // Default values (fallback) - These should be set via environment variables
  static String _getDefaultAndroidAppId() {
    if (kDebugMode) {
      debugPrint('⚠️ ADMOB_ANDROID_APP_ID not set in environment variables');
    }
    return 'ca-app-pub-3499593115543692~1498506854'; // Fallback value
  }

  static String _getDefaultIOSAppId() {
    if (kDebugMode) {
      debugPrint('⚠️ ADMOB_IOS_APP_ID not set in environment variables');
    }
    return 'ca-app-pub-3499593115543692~7549075426'; // Fallback value
  }

  static String _getDefaultAndroidBannerId() {
    if (kDebugMode) {
      debugPrint('⚠️ ADMOB_ANDROID_BANNER_ID not set in environment variables');
    }
    return 'ca-app-pub-3499593115543692/7394614482'; // Fallback value
  }

  static String _getDefaultIOSBannerId() {
    if (kDebugMode) {
      debugPrint('⚠️ ADMOB_IOS_BANNER_ID not set in environment variables');
    }
    return 'ca-app-pub-3499593115543692/3363871102'; // Fallback value
  }

  static String _getDefaultAndroidInterstitialId() {
    if (kDebugMode) {
      debugPrint(
        '⚠️ ADMOB_ANDROID_INTERSTITIAL_ID not set in environment variables',
      );
    }
    return 'ca-app-pub-3499593115543692/7181453654'; // Fallback value
  }

  static String _getDefaultIOSInterstitialId() {
    if (kDebugMode) {
      debugPrint(
        '⚠️ ADMOB_IOS_INTERSTITIAL_ID not set in environment variables',
      );
    }
    return 'ca-app-pub-3499593115543692/8013508657'; // Fallback value
  }

  static String _getDefaultAndroidRewardedId() {
    if (kDebugMode) {
      debugPrint(
        '⚠️ ADMOB_ANDROID_REWARDED_ID not set in environment variables',
      );
    }
    return 'ca-app-pub-3499593115543692/5817895627'; // Fallback value
  }

  static String _getDefaultIOSRewardedId() {
    if (kDebugMode) {
      debugPrint('⚠️ ADMOB_IOS_REWARDED_ID not set in environment variables');
    }
    return 'ca-app-pub-3499593115543692/3125989969'; // Fallback value
  }

  // Test Ad Unit IDs (for development)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  /// Get AdMob Application ID based on platform
  String get applicationId {
    if (Platform.isAndroid) {
      return _androidAppId;
    } else if (Platform.isIOS) {
      return _iosAppId;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Get Banner Ad Unit ID based on platform and environment
  String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerId;
    }

    if (Platform.isAndroid) {
      return _androidBannerId;
    } else if (Platform.isIOS) {
      return _iosBannerId;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Get Interstitial Ad Unit ID based on platform and environment
  String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialId;
    }

    if (Platform.isAndroid) {
      return _androidInterstitialId;
    } else if (Platform.isIOS) {
      return _iosInterstitialId;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Get Rewarded Ad Unit ID based on platform and environment
  String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedId;
    }

    if (Platform.isAndroid) {
      return _androidRewardedId;
    } else if (Platform.isIOS) {
      return _iosRewardedId;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Check if using test ads
  bool get isUsingTestAds => kDebugMode;

  /// Get current environment name
  String get environmentName {
    if (kDebugMode) {
      return 'Development';
    } else {
      return 'Production';
    }
  }

  /// Get platform name
  String get platformName {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  /// Log current configuration (for debugging)
  void logConfiguration() {
    if (kDebugMode) {
      debugPrint('🔧 Environment Configuration:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🌍 Environment: $environmentName');
      debugPrint('📱 Platform: $platformName');
      debugPrint('🧪 Using Test Ads: $isUsingTestAds');
      debugPrint('🏷️  Application ID: $applicationId');
      debugPrint('📺 Banner Ad Unit ID: $bannerAdUnitId');
      debugPrint('🔄 Interstitial Ad Unit ID: $interstitialAdUnitId');
      debugPrint('🎁 Rewarded Ad Unit ID: $rewardedAdUnitId');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Check if environment variables are set
      _checkEnvironmentVariables();
    }
  }

  /// Check if environment variables are properly set
  void _checkEnvironmentVariables() {
    final requiredVars = [
      'ADMOB_ANDROID_APP_ID',
      'ADMOB_IOS_APP_ID',
      'ADMOB_ANDROID_BANNER_ID',
      'ADMOB_IOS_BANNER_ID',
      'ADMOB_ANDROID_INTERSTITIAL_ID',
      'ADMOB_IOS_INTERSTITIAL_ID',
      'ADMOB_ANDROID_REWARDED_ID',
      'ADMOB_IOS_REWARDED_ID',
    ];

    debugPrint('🔍 Environment Variables Check:');
    for (final varName in requiredVars) {
      final value = Platform.environment[varName];
      if (value != null && value.isNotEmpty) {
        debugPrint('✅ $varName: Set');
      } else {
        debugPrint('⚠️ $varName: Not set (using fallback)');
      }
    }
  }

  /// Get configuration summary
  Map<String, dynamic> getConfigurationSummary() {
    return {
      'environment': environmentName,
      'platform': platformName,
      'isUsingTestAds': isUsingTestAds,
      'applicationId': applicationId,
      'bannerAdUnitId': bannerAdUnitId,
      'interstitialAdUnitId': interstitialAdUnitId,
      'rewardedAdUnitId': rewardedAdUnitId,
    };
  }

  /// Validate configuration
  bool validateConfiguration() {
    try {
      // Check if all required IDs are present
      final appId = applicationId;
      final bannerId = bannerAdUnitId;
      final interstitialId = interstitialAdUnitId;
      final rewardedId = rewardedAdUnitId;

      // Basic validation - check if IDs are not empty and have correct format
      final isValid =
          appId.isNotEmpty &&
          bannerId.isNotEmpty &&
          interstitialId.isNotEmpty &&
          rewardedId.isNotEmpty &&
          appId.contains('ca-app-pub-') &&
          bannerId.contains('ca-app-pub-') &&
          interstitialId.contains('ca-app-pub-') &&
          rewardedId.contains('ca-app-pub-');

      if (kDebugMode) {
        debugPrint(
          '✅ Configuration validation: ${isValid ? 'PASSED' : 'FAILED'}',
        );
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Configuration validation error: $e');
      }
      return false;
    }
  }
}
