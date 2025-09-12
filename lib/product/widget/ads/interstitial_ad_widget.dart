import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';
import 'banner_ad_widget.dart';

class InterstitialAdWidget {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  // Interstitial Ad Unit IDs (using AdUnitIds class)

  /// Load an interstitial ad
  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _isDebugMode()
          ? AdUnitIds.testInterstitial
          : GoogleAdsService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          print('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  /// Show the loaded interstitial ad
  static Future<void> showInterstitialAd() async {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('Interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          print('Interstitial ad dismissed');
          // Load a new ad for next time
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _isAdLoaded = false;
          print('Interstitial ad failed to show: $error');
        },
      );

      await _interstitialAd!.show();
    } else {
      print('No interstitial ad loaded to show');
    }
  }

  /// Check if an ad is loaded and ready to show
  static bool get isAdLoaded => _isAdLoaded;

  /// Dispose the current ad
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }

  /// Check if running in debug mode
  static bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}

/// Helper class to manage interstitial ads with automatic loading
class InterstitialAdManager {
  static InterstitialAdManager? _instance;

  InterstitialAdManager._internal();

  static InterstitialAdManager get instance {
    _instance ??= InterstitialAdManager._internal();
    return _instance!;
  }

  /// Initialize and load the first interstitial ad
  Future<void> initialize() async {
    await InterstitialAdWidget.loadInterstitialAd();
  }

  /// Show interstitial ad at appropriate times (e.g., between levels, after completing actions)
  Future<void> showAdOnAction() async {
    if (InterstitialAdWidget.isAdLoaded) {
      await InterstitialAdWidget.showInterstitialAd();
    } else {
      // If no ad is loaded, try to load one for next time
      await InterstitialAdWidget.loadInterstitialAd();
    }
  }

  /// Show ad when user navigates between major sections
  Future<void> showAdOnNavigation() async {
    if (InterstitialAdWidget.isAdLoaded) {
      await InterstitialAdWidget.showInterstitialAd();
    }
  }
}
