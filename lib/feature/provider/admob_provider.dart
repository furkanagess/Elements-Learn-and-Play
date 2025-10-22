import 'dart:io';
import 'package:elements_app/feature/service/google_ads_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/product/widget/ads/remove_ads_dialog.dart';
import 'package:elements_app/core/services/att_permission_service.dart';

/// The `AdmobProvider` class is responsible for managing interstitial ads using the
/// AdMob service. It provides methods for creating and displaying interstitial ads
/// in your Flutter application.
class AdmobProvider with ChangeNotifier {
  final int maxFailedAttempt = 3; // Reduced from 9999999 to reasonable limit
  int _interstitialLoadAttempts = 0;
  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  BuildContext? _lastAdContext; // Store context from last ad show

  // Route tracking for interstitial ads
  int _routeCounter = 0;
  static const int _routesBeforeAd = 15; // Show ad every 15 routes
  // Only increment once per real page navigation
  String? _lastRouteName;
  DateTime? _lastIncrementAt;
  final Duration _incrementCooldown = const Duration(milliseconds: 800);
  // Friendly pacing between ads
  final Duration _minIntervalBetweenAds = const Duration(seconds: 60);

  // Debug and analytics
  int _totalAdsShown = 0;
  int _totalRoutesTracked = 0;
  DateTime? _lastAdShownTime;

  /// Constructor that automatically creates the first interstitial ad
  AdmobProvider() {
    _createInterstitialAd();
  }

  /// Getter for current interstitial ad
  InterstitialAd? get interstitialAd => _interstitialAd;

  /// Getter for ad loading state
  bool get isAdLoading => _isAdLoading;

  /// Getter for current route counter
  int get routeCounter => _routeCounter;

  /// Getter for routes before ad
  int get routesBeforeAd => _routesBeforeAd;

  /// Getter for total ads shown
  int get totalAdsShown => _totalAdsShown;

  /// Getter for total routes tracked
  int get totalRoutesTracked => _totalRoutesTracked;

  /// Getter for last ad shown time
  DateTime? get lastAdShownTime => _lastAdShownTime;

  /// Creates and loads an interstitial ad.
  Future<void> _createInterstitialAd() async {
    if (_isAdLoading) return; // Prevent multiple simultaneous loads

    // Check ATT permission on iOS before creating ads
    if (Platform.isIOS) {
      final isAuthorized = await ATTPermissionService.instance
          .isPermissionAuthorized();
      if (!isAuthorized) {
        print(
          '📱 ATT permission not authorized, skipping interstitial ad creation',
        );
        return;
      }
    }

    try {
      _isAdLoading = true;
      notifyListeners();

      InterstitialAd.load(
        adUnitId: GoogleAdsService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialLoadAttempts = 0;
            _isAdLoading = false;

            // Set up ad callbacks
            _setupAdCallbacks(ad);

            notifyListeners();
            debugPrint('✅ Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialLoadAttempts += 1;
            _interstitialAd = null;
            _isAdLoading = false;

            debugPrint('❌ Interstitial ad failed to load: ${error.message}');
            debugPrint(
              '📊 Load attempts: $_interstitialLoadAttempts/$maxFailedAttempt',
            );

            if (_interstitialLoadAttempts < maxFailedAttempt) {
              // Exponential backoff retry
              final delay = Duration(seconds: _interstitialLoadAttempts * 2);
              debugPrint('🔄 Retrying in ${delay.inSeconds} seconds...');

              Future.delayed(delay, () {
                _createInterstitialAd();
              });
            } else {
              debugPrint('🚫 Max load attempts reached. Stopping retries.');
            }

            notifyListeners();
          },
        ),
      );
    } catch (e) {
      _isAdLoading = false;
      debugPrint('💥 Error creating interstitial ad: $e');
      notifyListeners();

      // Retry after delay
      if (_interstitialLoadAttempts < maxFailedAttempt) {
        Future.delayed(const Duration(seconds: 5), () {
          _createInterstitialAd();
        });
      }
    }
  }

  /// Sets up callbacks for the interstitial ad
  void _setupAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('✅ Interstitial ad dismissed');
        _totalAdsShown++;
        _lastAdShownTime = DateTime.now();

        ad.dispose();
        _interstitialAd = null;

        // Preload next ad with immersive mode
        _createInterstitialAd();

        // Show remove ads dialog after ad dismissal
        _showRemoveAdsDialogAfterAd();

        notifyListeners();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('❌ Interstitial ad failed to show: ${error.message}');

        ad.dispose();
        _interstitialAd = null;

        // Try to create a new ad with immersive mode
        _createInterstitialAd();
        notifyListeners();
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('🎬 Interstitial ad showed in immersive mode');

        // Tam ekran modunu zorla
        ad.setImmersiveMode(true);
      },
      onAdImpression: (InterstitialAd ad) {
        debugPrint('👁️ Interstitial ad impression recorded in fullscreen');
      },
    );
  }

  /// Displays the loaded interstitial ad.
  void showInterstitialAd([BuildContext? context]) {
    try {
      // Check if user is premium (if context is provided)
      if (context != null) {
        final purchaseProvider = context.read<PurchaseProvider>();
        if (purchaseProvider.isPremium) {
          debugPrint('🚫 Premium user - skipping interstitial ad');
          return;
        }
        // Store context for later use in dialog
        _lastAdContext = context;
      }

      if (_interstitialAd != null) {
        debugPrint('🎯 Showing interstitial ad...');

        // Tam ekran modunda göster
        _interstitialAd!.setImmersiveMode(true);

        // Reklamı göster
        _interstitialAd!
            .show()
            .then((_) {
              debugPrint('✅ Interstitial ad shown in fullscreen mode');
            })
            .catchError((error) {
              debugPrint('❌ Error showing interstitial ad: $error');
              _createInterstitialAd();
            });
      } else {
        debugPrint('⚠️ No interstitial ad available to show');
        // Try to create a new ad if none is available
        _createInterstitialAd();
      }
    } catch (e) {
      debugPrint('💥 Error showing interstitial ad: $e');
      // Try to create a new ad if showing fails
      _createInterstitialAd();
    }
  }

  /// Creates and shows an interstitial ad immediately (for testing purposes)
  void createAndShowInterstitialAd() {
    debugPrint('🚀 Creating and showing interstitial ad immediately');
    _createInterstitialAd();
    // Note: This will show the ad when it's loaded, not immediately
  }

  /// Shows remove ads dialog after interstitial ad dismissal
  void _showRemoveAdsDialogAfterAd() {
    // Add a small delay to ensure the ad is fully dismissed
    Future.delayed(const Duration(milliseconds: 500), () {
      // Use the stored context from the last ad show
      final context = _lastAdContext;
      if (context != null && context.mounted) {
        // Check if user is premium before showing dialog
        final purchaseProvider = context.read<PurchaseProvider>();
        if (!purchaseProvider.isPremium) {
          _showRemoveAdsDialog(context);
        }
      }
      // Clear the stored context
      _lastAdContext = null;
    });
  }

  /// Shows the remove ads dialog
  void _showRemoveAdsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const RemoveAdsDialog(),
    );
  }

  /// Tracks all route changes (push, pop, replace) and shows interstitial ad every 15 routes
  void onRouteChanged({
    String? routeName,
    bool isPageRoute = true,
    BuildContext? context,
  }) {
    // Only track page routes (ignore dialogs/sheets if flagged)
    if (!isPageRoute) return;

    final now = DateTime.now();

    // De-duplicate rapid multiple notifications for the same transition
    final withinCooldown =
        _lastIncrementAt != null &&
        now.difference(_lastIncrementAt!) < _incrementCooldown;
    final isSameRoute = routeName != null && routeName == _lastRouteName;

    if (withinCooldown || isSameRoute) {
      debugPrint(
        '⏱️ Skipping duplicate route increment (cooldown or same route)',
      );
      return;
    }

    _routeCounter = (_routeCounter + 1).clamp(0, _routesBeforeAd);
    _totalRoutesTracked++;
    _lastIncrementAt = now;
    if (routeName != null) _lastRouteName = routeName;

    debugPrint('🛣️ Route changed. Counter: $_routeCounter/$_routesBeforeAd');
    debugPrint('📊 Total routes tracked: $_totalRoutesTracked');

    // Show interstitial ad every 15 page navigations, respecting pacing
    if (_routeCounter >= _routesBeforeAd) {
      final canShowByTime =
          _lastAdShownTime == null ||
          now.difference(_lastAdShownTime!) >= _minIntervalBetweenAds;
      if (!canShowByTime) {
        debugPrint('⏳ Ad pacing active. Will wait before showing.');
        return; // keep counter at threshold; will show when time allows
      }
      debugPrint('🎯 Route threshold reached! Showing interstitial ad...');
      showInterstitialAd(context);

      // Reset both counters after showing ad
      _routeCounter = 0;
      _totalRoutesTracked = 0;

      debugPrint('📈 Ad shown. Total ads shown: $_totalAdsShown');
      debugPrint('🔄 Route counters reset to 0');
    }
  }

  /// @deprecated Use onRouteChanged() instead
  /// This method is kept for backward compatibility
  void onBackNavigation([BuildContext? context]) =>
      onRouteChanged(context: context);

  /// Gets debug information about the current state
  Map<String, dynamic> getDebugInfo() {
    return {
      'routeCounter': _routeCounter,
      'routesBeforeAd': _routesBeforeAd,
      'totalAdsShown': _totalAdsShown,
      'currentRouteCount':
          _totalRoutesTracked, // Current route count since last ad
      'lastAdShownTime': _lastAdShownTime?.toIso8601String(),
      'isAdLoading': _isAdLoading,
      'interstitialLoadAttempts': _interstitialLoadAttempts,
      'hasInterstitialAd': _interstitialAd != null,
      'nextAdIn': _routesBeforeAd - _routeCounter, // Routes until next ad
    };
  }

  /// Disposes the provider and cleans up resources
  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
