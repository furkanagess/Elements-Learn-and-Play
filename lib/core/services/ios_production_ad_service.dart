import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';

/// Service to monitor and optimize iOS production ad performance
class IOSProductionAdService {
  static IOSProductionAdService? _instance;

  IOSProductionAdService._internal();

  static IOSProductionAdService get instance {
    _instance ??= IOSProductionAdService._internal();
    return _instance!;
  }

  int _bannerAdLoadCount = 0;
  int _interstitialAdLoadCount = 0;
  int _rewardedAdLoadCount = 0;
  int _bannerAdShowCount = 0;
  int _interstitialAdShowCount = 0;
  int _rewardedAdShowCount = 0;
  int _bannerAdErrorCount = 0;
  int _interstitialAdErrorCount = 0;
  int _rewardedAdErrorCount = 0;

  /// Initialize iOS production ad monitoring
  Future<void> initialize() async {
    if (!Platform.isIOS) return;

    try {
      // Pre-warm ad units for better performance
      await _preWarmAdUnits();

      if (kDebugMode) {
        debugPrint('✅ iOS production ad service initialized');
        debugPrint('📱 Ad Unit IDs:');
        debugPrint('   - Banner: ${GoogleAdsService.bannerAdUnitId}');
        debugPrint(
          '   - Interstitial: ${GoogleAdsService.interstitialAdUnitId}',
        );
        debugPrint('   - Rewarded: ${GoogleAdsService.rewardedAdUnitId}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing iOS production ad service: $e');
      }
    }
  }

  /// Pre-warm ad units for better performance
  Future<void> _preWarmAdUnits() async {
    try {
      // Pre-warm banner ad
      final bannerAd = BannerAd(
        adUnitId: GoogleAdsService.bannerAdUnitId,
        size: AdSize.banner,
        request: _createProductionAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAdLoadCount++;
            if (kDebugMode) {
              debugPrint('✅ Banner ad pre-warmed successfully');
            }
            ad.dispose();
          },
          onAdFailedToLoad: (ad, error) {
            _bannerAdErrorCount++;
            if (kDebugMode) {
              debugPrint('❌ Banner ad pre-warm failed: $error');
            }
            ad.dispose();
          },
        ),
      );
      bannerAd.load();

      // Pre-warm interstitial ad
      await InterstitialAd.load(
        adUnitId: GoogleAdsService.interstitialAdUnitId,
        request: _createProductionAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAdLoadCount++;
            if (kDebugMode) {
              debugPrint('✅ Interstitial ad pre-warmed successfully');
            }
            ad.dispose();
          },
          onAdFailedToLoad: (error) {
            _interstitialAdErrorCount++;
            if (kDebugMode) {
              debugPrint('❌ Interstitial ad pre-warm failed: $error');
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error pre-warming ad units: $e');
      }
    }
  }

  /// Create optimized ad request for iOS production
  AdRequest _createProductionAdRequest() {
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
        'knowledge',
        'research',
        'laboratory',
        'experiment',
      ],
      contentUrl: 'https://elements-app.com',
      nonPersonalizedAds: false,
    );
  }

  /// Log ad performance metrics
  void logAdPerformance() {
    if (kDebugMode) {
      debugPrint('📊 iOS Ad Performance Metrics:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📺 Banner Ads:');
      debugPrint('   - Loaded: $_bannerAdLoadCount');
      debugPrint('   - Shown: $_bannerAdShowCount');
      debugPrint('   - Errors: $_bannerAdErrorCount');
      debugPrint(
        '   - Success Rate: ${_calculateSuccessRate(_bannerAdLoadCount, _bannerAdErrorCount)}%',
      );
      debugPrint('');
      debugPrint('🔄 Interstitial Ads:');
      debugPrint('   - Loaded: $_interstitialAdLoadCount');
      debugPrint('   - Shown: $_interstitialAdShowCount');
      debugPrint('   - Errors: $_interstitialAdErrorCount');
      debugPrint(
        '   - Success Rate: ${_calculateSuccessRate(_interstitialAdLoadCount, _interstitialAdErrorCount)}%',
      );
      debugPrint('');
      debugPrint('🎁 Rewarded Ads:');
      debugPrint('   - Loaded: $_rewardedAdLoadCount');
      debugPrint('   - Shown: $_rewardedAdShowCount');
      debugPrint('   - Errors: $_rewardedAdErrorCount');
      debugPrint(
        '   - Success Rate: ${_calculateSuccessRate(_rewardedAdLoadCount, _rewardedAdErrorCount)}%',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Calculate success rate percentage
  double _calculateSuccessRate(int loaded, int errors) {
    if (loaded == 0) return 0.0;
    return ((loaded - errors) / loaded * 100).roundToDouble();
  }

  /// Track ad events
  void trackBannerAdLoad() => _bannerAdLoadCount++;
  void trackBannerAdShow() => _bannerAdShowCount++;
  void trackBannerAdError() => _bannerAdErrorCount++;

  void trackInterstitialAdLoad() => _interstitialAdLoadCount++;
  void trackInterstitialAdShow() => _interstitialAdShowCount++;
  void trackInterstitialAdError() => _interstitialAdErrorCount++;

  void trackRewardedAdLoad() => _rewardedAdLoadCount++;
  void trackRewardedAdShow() => _rewardedAdShowCount++;
  void trackRewardedAdError() => _rewardedAdErrorCount++;

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    return {
      'banner': {
        'loaded': _bannerAdLoadCount,
        'shown': _bannerAdShowCount,
        'errors': _bannerAdErrorCount,
        'successRate': _calculateSuccessRate(
          _bannerAdLoadCount,
          _bannerAdErrorCount,
        ),
      },
      'interstitial': {
        'loaded': _interstitialAdLoadCount,
        'shown': _interstitialAdShowCount,
        'errors': _interstitialAdErrorCount,
        'successRate': _calculateSuccessRate(
          _interstitialAdLoadCount,
          _interstitialAdErrorCount,
        ),
      },
      'rewarded': {
        'loaded': _rewardedAdLoadCount,
        'shown': _rewardedAdShowCount,
        'errors': _rewardedAdErrorCount,
        'successRate': _calculateSuccessRate(
          _rewardedAdLoadCount,
          _rewardedAdErrorCount,
        ),
      },
    };
  }

  /// Reset all counters (for testing)
  void resetCounters() {
    _bannerAdLoadCount = 0;
    _interstitialAdLoadCount = 0;
    _rewardedAdLoadCount = 0;
    _bannerAdShowCount = 0;
    _interstitialAdShowCount = 0;
    _rewardedAdShowCount = 0;
    _bannerAdErrorCount = 0;
    _interstitialAdErrorCount = 0;
    _rewardedAdErrorCount = 0;
  }
}
