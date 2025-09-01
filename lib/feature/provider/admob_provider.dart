import 'package:elements_app/feature/service/google_ads_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// The `AdmobProvider` class is responsible for managing interstitial ads using the
/// AdMob service. It provides methods for creating and displaying interstitial ads
/// in your Flutter application.
class AdmobProvider with ChangeNotifier {
  final int maxFailedAttempt = 9999999;
  int intersititialLoadAttempts = 0;
  InterstitialAd? interstitialAd;

  // Route tracking for interstitial ads
  int _routeCounter = 0;
  static const int _routesBeforeAd = 15; // Show ad every 15 routes

  /// Constructor that automatically creates the first interstitial ad
  AdmobProvider() {
    createInterstitialAd();
  }

  /// Creates and loads an interstitial ad.
  void createInterstitialAd() {
    try {
      InterstitialAd.load(
        adUnitId: GoogleAdsService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
            intersititialLoadAttempts = 0;
            notifyListeners(); // Notify listeners of data changes
          },
          onAdFailedToLoad: (LoadAdError error) {
            intersititialLoadAttempts += 1;
            interstitialAd = null;
            if (intersititialLoadAttempts < maxFailedAttempt) {
              // Retry after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                createInterstitialAd();
              });
            }
            notifyListeners(); // Notify listeners of data changes
          },
        ),
      );
    } catch (e) {
      // Handle any exceptions during ad loading
      print('Error creating interstitial ad: $e');
    }
  }

  /// Displays the loaded interstitial ad.
  void showInterstitialAd() {
    try {
      if (interstitialAd != null) {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            createInterstitialAd();
            notifyListeners(); // Notify listeners of data changes
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            ad.dispose();
            createInterstitialAd();
            notifyListeners(); // Notify listeners of data changes
          },
        );
        interstitialAd!.show();
      }
    } catch (e) {
      // Handle any exceptions during ad showing
      print('Error showing interstitial ad: $e');
      // Try to create a new ad if showing fails
      createInterstitialAd();
    }
  }

  /// Creates and shows an interstitial ad.
  void createAndShowInterstitialAd() {
    createInterstitialAd();
    showInterstitialAd();
  }

  /// Tracks route changes and shows interstitial ad every 15 routes
  void onRouteChanged() {
    _routeCounter++;

    // Show interstitial ad every 15 routes
    if (_routeCounter >= _routesBeforeAd) {
      showInterstitialAd();
      _routeCounter = 0; // Reset counter after showing ad
    }
  }

  /// Get current route counter (for debugging purposes)
  int get routeCounter => _routeCounter;

  /// Get routes before ad (for debugging purposes)
  int get routesBeforeAd => _routesBeforeAd;
}
