import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:elements_app/feature/service/google_ads_service.dart';

/// Service to handle Android production-specific optimizations
class AndroidProductionService {
  static AndroidProductionService? _instance;

  AndroidProductionService._internal();

  static AndroidProductionService get instance {
    _instance ??= AndroidProductionService._internal();
    return _instance!;
  }

  bool _isInitialized = false;

  /// Initialize Android production optimizations
  Future<void> initialize() async {
    if (!Platform.isAndroid || _isInitialized) return;

    try {
      if (kDebugMode) {
        debugPrint('🤖 Initializing Android production service...');
      }

      // Configure AdMob for Android production
      await _configureAdMobForProduction();

      // Pre-warm critical services
      await _preWarmServices();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ Android production service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing Android production service: $e');
      }
      // Still mark as initialized to prevent retry loops
      _isInitialized = true;
    }
  }

  /// Configure AdMob for Android production
  Future<void> _configureAdMobForProduction() async {
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          testDeviceIds: kDebugMode
              ? []
              : null, // No test devices in production
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );

      if (kDebugMode) {
        debugPrint('✅ Android AdMob configuration updated for production');
        debugPrint('📱 Android AdMob configuration:');
        debugPrint('   - Child-directed treatment: No');
        debugPrint('   - Under age of consent: No');
        debugPrint('   - Max content rating: G');
        debugPrint('   - Test devices: ${kDebugMode ? "Enabled" : "Disabled"}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error configuring AdMob for Android: $e');
      }
    }
  }

  /// Pre-warm critical services
  Future<void> _preWarmServices() async {
    try {
      // Pre-warm banner ad for better performance
      final bannerAd = BannerAd(
        adUnitId: GoogleAdsService.bannerAdUnitId,
        size: AdSize.banner,
        request: _createProductionAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (kDebugMode) {
              debugPrint('✅ Android banner ad pre-warmed successfully');
            }
            ad.dispose();
          },
          onAdFailedToLoad: (ad, error) {
            if (kDebugMode) {
              debugPrint('❌ Android banner ad pre-warm failed: $error');
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
            if (kDebugMode) {
              debugPrint('✅ Android interstitial ad pre-warmed successfully');
            }
            ad.dispose();
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) {
              debugPrint('❌ Android interstitial ad pre-warm failed: $error');
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error pre-warming Android services: $e');
      }
    }
  }

  /// Create optimized ad request for Android production
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

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Log Android production status
  void logProductionStatus() {
    if (kDebugMode) {
      debugPrint('🤖 Android Production Status:');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📱 Platform: Android');
      debugPrint('🔧 Initialized: $_isInitialized');
      debugPrint('📺 Banner Ad Unit ID: ${GoogleAdsService.bannerAdUnitId}');
      debugPrint(
        '🔄 Interstitial Ad Unit ID: ${GoogleAdsService.interstitialAdUnitId}',
      );
      debugPrint(
        '🎁 Rewarded Ad Unit ID: ${GoogleAdsService.rewardedAdUnitId}',
      );
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  /// Reset initialization state (for testing)
  void reset() {
    _isInitialized = false;
  }
}
