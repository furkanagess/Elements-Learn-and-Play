import 'dart:io';
import 'package:elements_app/feature/service/google_ads_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/core/services/att_permission_service.dart';

/// The `BannerAdsProvider` class is responsible for managing banner ads using the
/// AdMob service. It provides methods for creating and displaying banner ads
/// in your Flutter application.
class BannerAdsProvider with ChangeNotifier {
  BannerAd? bannerAd;
  bool _isBannerAdLoaded = false;

  /// Getter to check if banner ad is loaded
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// Creates and loads a banner ad.
  Future<void> createBannerAd() async {
    try {
      // Check ATT permission on iOS before creating ads
      if (Platform.isIOS) {
        final isAuthorized = await ATTPermissionService.instance
            .isPermissionAuthorized();
        if (!isAuthorized) {
          print(
            '📱 ATT permission not authorized, skipping banner ad creation',
          );
          return;
        }
      }

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
  Widget? getBannerAdWidget([BuildContext? context]) {
    // Check if user is premium (if context is provided)
    if (context != null) {
      final purchaseProvider = context.read<PurchaseProvider>();
      if (purchaseProvider.isPremium) {
        return null; // Don't show banner ads for premium users
      }
    }

    if (_isBannerAdLoaded && bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: bannerAd!.size.width.toDouble(),
        height: bannerAd!.size.height.toDouble(),
        child: _createNewBannerAdWidget(),
      );
    }
    return null;
  }

  /// Returns a banner ad widget with loading state.
  Widget getBannerAdWidgetWithLoading([BuildContext? context]) {
    // Check if user is premium (if context is provided)
    if (context != null) {
      final purchaseProvider = context.read<PurchaseProvider>();
      if (purchaseProvider.isPremium) {
        return const SizedBox.shrink(); // Don't show ads for premium users
      }
    }

    return Container(
      alignment: Alignment.center,
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: _isBannerAdLoaded && bannerAd != null
          ? _createNewBannerAdWidget()
          : Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: Lottie.asset(
                  AssetConstants.instance.lottieLoadingChemistry,
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
            ),
    );
  }

  /// Creates a new banner ad widget to avoid the "already in widget tree" error
  Widget _createNewBannerAdWidget() {
    final newBannerAd = BannerAd(
      adUnitId: bannerAd!.adUnitId,
      size: bannerAd!.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Ad loaded successfully
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
        onAdOpened: (ad) {
          // Handle ad opened
        },
        onAdClosed: (ad) {
          // Handle ad closed
        },
      ),
    );

    newBannerAd.load();

    return AdWidget(ad: newBannerAd);
  }
}
