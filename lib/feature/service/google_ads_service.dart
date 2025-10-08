import 'package:elements_app/core/config/environment_config.dart';

/// The `GoogleAdsService` class provides access to the AdMob ad unit IDs based on the platform.
/// It uses EnvironmentConfig for secure and environment-aware ad unit management.
class GoogleAdsService {
  static final EnvironmentConfig _config = EnvironmentConfig.instance;

  /// Returns the AdMob application ID based on platform and environment.
  static String get applicationId => _config.applicationId;

  /// Returns the AdMob interstitial ad unit ID based on platform and environment.
  static String get interstitialAdUnitId => _config.interstitialAdUnitId;

  /// Returns the AdMob banner ad unit ID based on platform and environment.
  static String get bannerAdUnitId => _config.bannerAdUnitId;

  /// Returns the AdMob rewarded ad unit ID based on platform and environment.
  static String get rewardedAdUnitId => _config.rewardedAdUnitId;

  /// Check if using test ads (development mode)
  static bool get isUsingTestAds => _config.isUsingTestAds;

  /// Get current environment name
  static String get environmentName => _config.environmentName;

  /// Get platform name
  static String get platformName => _config.platformName;

  /// Log current ad configuration
  static void logConfiguration() => _config.logConfiguration();

  /// Get configuration summary
  static Map<String, dynamic> getConfigurationSummary() =>
      _config.getConfigurationSummary();

  /// Validate ad configuration
  static bool validateConfiguration() => _config.validateConfiguration();
}
