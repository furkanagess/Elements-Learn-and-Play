import 'package:elements_app/feature/provider/banner_ads_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A reusable widget for displaying banner ads in the application.
/// This widget automatically handles loading states and error handling.
class BannerAdsWidget extends StatefulWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool showLoadingIndicator;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const BannerAdsWidget({
    super.key,
    this.margin,
    this.padding,
    this.showLoadingIndicator = false,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  State<BannerAdsWidget> createState() => _BannerAdsWidgetState();
}

class _BannerAdsWidgetState extends State<BannerAdsWidget> {
  @override
  void initState() {
    super.initState();
    // Create banner ad when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerAdsProvider>().createBannerAd();
    });
  }

  @override
  void dispose() {
    // Dispose banner ad when widget is disposed
    context.read<BannerAdsProvider>().disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerAdsProvider>(
      builder: (context, bannerAdsProvider, child) {
        return Container(
          margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
          padding: widget.padding,
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ??
                AppColors.white.withValues(alpha: 0.05),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          ),
          child: widget.showLoadingIndicator
              ? bannerAdsProvider.getBannerAdWidgetWithLoading()
              : bannerAdsProvider.getBannerAdWidget() ??
                    const SizedBox.shrink(),
        );
      },
    );
  }
}

/// A compact banner ads widget for smaller spaces.
class CompactBannerAdsWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const CompactBannerAdsWidget({
    super.key,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerAdsProvider>(
      builder: (context, bannerAdsProvider, child) {
        final bannerWidget = bannerAdsProvider.getBannerAdWidget();

        if (bannerWidget == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.white.withValues(alpha: 0.05),
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: bannerWidget,
        );
      },
    );
  }
}
