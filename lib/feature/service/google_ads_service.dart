import 'dart:io';

/// The `GoogleAdsService` class provides access to the AdMob ad unit IDs based on the platform.
/// It returns the appropriate ad unit IDs for both Android and iOS platforms.
class GoogleAdsService {
  /// Returns the AdMob application ID based on platform.
  static String get applicationId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3499593115543692~1498506854";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3499593115543692~7549075426";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Returns the AdMob interstitial ad unit ID based on platform.
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3499593115543692/7181453654";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3499593115543692/8013508657";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Returns the AdMob banner ad unit ID based on platform.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3499593115543692/7394614482";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3499593115543692/3363871102";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
