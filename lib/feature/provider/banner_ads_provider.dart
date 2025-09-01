import 'package:elements_app/feature/service/google_ads_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// The `BannerAdsProvider` class is responsible for managing banner ads using the
/// AdMob service. It provides methods for creating and displaying banner ads
/// in your Flutter application.
class BannerAdsProvider with ChangeNotifier {
  BannerAd? bannerAd;
  bool _isBannerAdLoaded = false;

  /// Getter to check if banner ad is loaded
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// Creates and loads a banner ad.
  void createBannerAd() {
    try {
      bannerAd = BannerAd(
        adUnitId: GoogleAdsService.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            ad.dispose();
            notifyListeners();
          },
          onAdOpened: (ad) {
            // Handle ad opened
          },
          onAdClosed: (ad) {
            // Handle ad closed
          },
        ),
      );

      bannerAd!.load();
    } catch (e) {
      print('Error creating banner ad: $e');
    }
  }

  /// Disposes the banner ad.
  void disposeBannerAd() {
    bannerAd?.dispose();
    _isBannerAdLoaded = false;
    notifyListeners();
  }

  /// Returns the banner ad widget if loaded, otherwise returns null.
  Widget? getBannerAdWidget() {
    if (_isBannerAdLoaded && bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: bannerAd!.size.width.toDouble(),
        height: bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: bannerAd!),
      );
    }
    return null;
  }

  /// Returns a banner ad widget with loading state.
  Widget getBannerAdWidgetWithLoading() {
    return Container(
      alignment: Alignment.center,
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: _isBannerAdLoaded && bannerAd != null
          ? AdWidget(ad: bannerAd!)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
