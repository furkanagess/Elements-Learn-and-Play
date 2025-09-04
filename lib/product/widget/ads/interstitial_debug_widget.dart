import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A debug widget that displays information about interstitial ads
/// This widget is only visible in debug mode and shows:
/// - Current route counter
/// - Total routes tracked
/// - Total ads shown
/// - Last ad shown time
/// - Ad loading status
class InterstitialDebugWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const InterstitialDebugWidget({
    super.key,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Consumer<AdmobProvider>(
      builder: (context, admobProvider, child) {
        final debugInfo = admobProvider.getDebugInfo();

        return Container(
          margin: margin ?? const EdgeInsets.all(16),
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glowGreen.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.bug_report,
                    color: AppColors.glowGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Interstitial Ads Debug',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Debug Information
              _buildDebugRow('Route Counter',
                  '${debugInfo['routeCounter']}/${debugInfo['routesBeforeAd']}'),
              _buildDebugRow('Next Ad In', '${debugInfo['nextAdIn']} routes'),
              _buildDebugRow(
                  'Total Routes', '${debugInfo['totalRoutesTracked']}'),
              _buildDebugRow(
                  'Total Ads Shown', '${debugInfo['totalAdsShown']}'),
              _buildDebugRow('Ad Loading',
                  debugInfo['isAdLoading'] ? '🔄 Loading...' : '✅ Ready'),
              _buildDebugRow(
                  'Has Ad', debugInfo['hasInterstitialAd'] ? '✅ Yes' : '❌ No'),

              if (debugInfo['lastAdShownTime'] != null)
                _buildDebugRow(
                    'Last Ad', _formatDateTime(debugInfo['lastAdShownTime'])),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.glowGreen,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Never';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}

/// A compact version of the debug widget for smaller spaces
class CompactInterstitialDebugWidget extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const CompactInterstitialDebugWidget({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Consumer<AdmobProvider>(
      builder: (context, admobProvider, child) {
        return Container(
          margin: margin ?? const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.glowGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bug_report,
                color: AppColors.glowGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${admobProvider.routeCounter}/${admobProvider.routesBeforeAd} | ${admobProvider.routesBeforeAd - admobProvider.routeCounter} to ad | ${admobProvider.totalAdsShown} ads',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
