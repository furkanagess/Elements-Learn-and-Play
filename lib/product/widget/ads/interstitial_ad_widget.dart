import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';

class InterstitialAdWidget {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;
  static int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  /// Load an interstitial ad with iOS-specific configuration
  static Future<void> loadInterstitialAd() async {
    if (_loadAttempts >= _maxLoadAttempts) {
      debugPrint('❌ Max interstitial ad load attempts reached');
      return;
    }

    try {
      await InterstitialAd.load(
        adUnitId: GoogleAdsService.interstitialAdUnitId,
        request: _createAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isAdLoaded = true;
            _loadAttempts = 0;
            debugPrint('✅ Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            _isAdLoaded = false;
            _loadAttempts++;
            debugPrint(
              '❌ Interstitial ad failed to load (attempt $_loadAttempts): $error',
            );

            // Retry loading after delay if attempts remaining
            if (_loadAttempts < _maxLoadAttempts) {
              Future.delayed(Duration(seconds: _loadAttempts * 3), () {
                loadInterstitialAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Exception loading interstitial ad: $e');
      _loadAttempts++;
    }
  }

  /// Create platform-specific ad request
  static AdRequest _createAdRequest() {
    if (Platform.isIOS) {
      // iOS-specific ad request configuration for production
      return const AdRequest(
        keywords: [
          'education',
          'science',
          'chemistry',
          'periodic table',
          'learning',
          'study',
          'academic',
          'school',
          'university',
          'student',
        ],
        contentUrl: 'https://elements-app.com',
        nonPersonalizedAds: false,
      );
    } else {
      return const AdRequest();
    }
  }

  /// Show the loaded interstitial ad
  static Future<void> showInterstitialAd([BuildContext? context]) async {
    // Check if user is premium (if context is provided)
    if (context != null) {
      final purchaseProvider = context.read<PurchaseProvider>();
      if (purchaseProvider.isPremium) {
        print('🚫 Premium user - skipping interstitial ad');
        return;
      }
    }

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
  Future<void> showAdOnAction([BuildContext? context]) async {
    if (InterstitialAdWidget.isAdLoaded) {
      await InterstitialAdWidget.showInterstitialAd(context);
    } else {
      // If no ad is loaded, try to load one for next time
      await InterstitialAdWidget.loadInterstitialAd();
    }
  }

  /// Show ad when user navigates between major sections
  Future<void> showAdOnNavigation([BuildContext? context]) async {
    if (InterstitialAdWidget.isAdLoaded) {
      await InterstitialAdWidget.showInterstitialAd(context);
    }
  }
}
