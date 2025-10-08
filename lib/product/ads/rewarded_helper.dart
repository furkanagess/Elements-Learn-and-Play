import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';

/// Simple helper to show a rewarded ad and invoke [onRewardEarned]
/// when the user successfully earns the reward.
class RewardedHelper {
  // Use centralized ad unit IDs from GoogleAdsService

  // Cached rewarded interstitial to reduce latency
  static RewardedInterstitialAd? _cachedAd;
  static bool _isLoading = false;
  static DateTime? _lastLoadAt;

  /// Preload a rewarded ad as early as possible
  static Future<void> initialize() async {
    await _loadIfNeeded(force: true);
  }

  static Future<void> _loadIfNeeded({bool force = false}) async {
    if (_cachedAd != null || _isLoading) return;
    if (!force &&
        _lastLoadAt != null &&
        DateTime.now().difference(_lastLoadAt!) < const Duration(seconds: 5)) {
      return;
    }
    _isLoading = true;
    _lastLoadAt = DateTime.now();

    final adUnitId = GoogleAdsService.rewardedAdUnitId;
    try {
      await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: _createAdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            if (kDebugMode) debugPrint('✅ RewardedInterstitial cached');
            _cachedAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode)
              debugPrint('❌ RewardedInterstitial preload failed: $error');
            _isLoading = false;
            _cachedAd = null;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode)
        debugPrint('❌ RewardedInterstitial preload exception: $e');
      _isLoading = false;
      _cachedAd = null;
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

  /// Loads and shows a rewarded ad. Returns true if reward earned.
  ///
  /// Note: Both Android and iOS units are configured as Rewarded Interstitial
  /// according to your AdMob setup screenshots.
  static Future<bool> showRewardedAd({required BuildContext context}) async {
    try {
      // Check if user is premium
      final purchaseProvider = context.read<PurchaseProvider>();
      if (purchaseProvider.isPremium) {
        if (kDebugMode) debugPrint('🚫 Premium user - skipping rewarded ad');
        return true; // Return true to simulate successful reward for premium users
      }

      final completer = ValueNotifier<bool?>(null);

      // Use cached ad if available; otherwise load now
      if (_cachedAd == null) {
        await _loadIfNeeded(force: true);
      }

      final ad = _cachedAd;
      if (ad == null) {
        // Fallback: no ad available
        if (kDebugMode) debugPrint('⚠️ No rewarded interstitial cached');
        return false;
      }

      // Clear cache before showing
      _cachedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdFailedToShowFullScreenContent: (ad, err) {
          if (kDebugMode)
            debugPrint('❌ RewardedInterstitial show failed: $err');
          ad.dispose();
          completer.value = false;
          _loadIfNeeded();
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          completer.value ??= false;
          _loadIfNeeded();
        },
      );

      ad.show(
        onUserEarnedReward: (adWithoutView, reward) {
          if (kDebugMode) {
            debugPrint('✅ Reward earned: ${reward.amount} ${reward.type}');
          }
          completer.value = true;
        },
      );

      // Wait for result
      while (completer.value == null) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return completer.value ?? false;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Rewarded exception: $e');
      return false;
    }
  }
}
