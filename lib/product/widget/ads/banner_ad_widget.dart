import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/core/services/ios_ad_debug_service.dart';
import 'package:elements_app/core/services/ios_production_ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.adSize = AdSize.banner,
    this.margin,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  @override
  void initState() {
    super.initState();
    // Add delay for iOS to ensure proper initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadBannerAd();
      }
    });
  }

  void _loadBannerAd() {
    if (_isLoading || _loadAttempts >= _maxLoadAttempts) return;

    setState(() {
      _isLoading = true;
    });

    // Log ad request for debugging
    IOSAdDebugService.instance.logAdRequest('Banner', widget.adUnitId);

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: widget.adSize,
      request: _createAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isLoading = false;
              _loadAttempts = 0;
            });
            IOSAdDebugService.instance.logAdLoadSuccess('Banner');
            IOSProductionAdService.instance.trackBannerAdLoad();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _loadAttempts++;
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isLoading = false;
            });
            IOSAdDebugService.instance.logAdLoadFailure('Banner', error);
            IOSProductionAdService.instance.trackBannerAdError();

            // Retry loading after delay if attempts remaining
            if (_loadAttempts < _maxLoadAttempts) {
              Future.delayed(Duration(seconds: _loadAttempts * 2), () {
                if (mounted) {
                  _loadBannerAd();
                }
              });
            }
          }
        },
        onAdOpened: (ad) {
          IOSAdDebugService.instance.logAdShowSuccess('Banner');
          IOSProductionAdService.instance.trackBannerAdShow();
        },
        onAdClosed: (ad) {
          debugPrint('📱 Banner ad closed');
        },
      ),
    );

    _bannerAd!.load();
  }

  AdRequest _createAdRequest() {
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

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is premium
    final purchaseProvider = context.watch<PurchaseProvider>();
    if (purchaseProvider.isPremium) {
      return const SizedBox.shrink(); // Don't show ads for premium users
    }

    // Show loading indicator while ad is loading
    if (_isLoading) {
      return Container(
        height: widget.adSize.height.toDouble(),
        margin: widget.margin,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Show ad if loaded successfully
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: widget.margin,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Show nothing if ad failed to load after all attempts
    return const SizedBox.shrink();
  }
}
