import 'dart:io';

/// The `GoogleAdsService` class provides access to the AdMob ad unit IDs based on the platform.
/// It returns the appropriate ad unit IDs for Android platforms and throws an error for unsupported platforms.
class GoogleAdsService {
  /// Returns the AdMob application ID for Android platforms.
  static String get applicationId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3499593115543692~1498506854";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Returns the AdMob interstitial ad unit ID for Android platforms.
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3499593115543692/7181453654";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Returns the AdMob banner ad unit ID for Android platforms.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3499593115543692/7394614482";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
