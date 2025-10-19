import 'dart:io';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/view/home/widgets/element_of_day_widget.dart';
import 'package:elements_app/feature/view/home/widgets/features_grid_widget.dart';
import 'package:elements_app/feature/view/home/widgets/hero_section_widget.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/navigation/app_bottom_navbar.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/core/services/widget/element_home_widget_service.dart';
import 'package:elements_app/core/services/first_time_service.dart';
import 'package:elements_app/core/services/notifications/permission_service.dart';
import 'package:elements_app/product/widget/premium/first_time_paywall.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
    // Load elements when the home view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodicTableProvider>().loadElements();
      // Update widget after elements are loaded
      ElementHomeWidgetService.updateFromContext(context);
      // Check if we should show paywall
      _checkAndShowPaywall();
      // Check notification permission for iOS
      _checkNotificationPermission();
    });
  }

  Future<void> _checkAndShowPaywall() async {
    try {
      final purchaseProvider = context.read<PurchaseProvider>();
      final shouldShow = await FirstTimeService.instance.shouldShowPaywall(
        isPremium: purchaseProvider.isPremium,
      );

      if (shouldShow && mounted) {
        // Add a small delay to ensure the home view is fully loaded
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => FirstTimePaywall(
              onDismiss: () async {
                // Only mark paywall as shown, don't complete the entire first-time flow
                await FirstTimeService.instance.markPaywallAsShownOnly();
              },
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking paywall: $e');
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      // Only check on iOS
      if (!Platform.isIOS) return;

      // Wait a bit for the UI to be fully loaded
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check if permission is already granted
      final isGranted = await NotificationPermissionService.instance
          .isPermissionGranted();

      if (!isGranted) {
        // Show custom permission dialog
        final shouldRequest = await NotificationPermissionService.instance
            .showPermissionDialog(context);

        if (shouldRequest && mounted) {
          // Request system permission
          await NotificationPermissionService.instance
              .requestPermissionWithDelay(
                context: context,
                delay: Duration.zero,
              );
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking notification permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.expand(
          child: Stack(
            children: [
              // Background pattern removed for a cleaner look

              // Premium Status Indicator (top-right corner)
              Positioned(
                top: 50,
                right: 20,
                child: Consumer<PurchaseProvider>(
                  builder: (context, purchaseProvider, child) {
                    if (purchaseProvider.isPremium) {
                      return _PremiumBadge();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Main Content
              Positioned.fill(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 72),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 100,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20),

                              // Element of the Day Section
                              RepaintBoundary(child: ElementOfDayWidget()),

                              SizedBox(height: 20),

                              // Hero Image Section (Periodic Table)
                              RepaintBoundary(child: HeroSectionWidget()),

                              SizedBox(height: 20),

                              // Main Features Grid
                              RepaintBoundary(child: FeaturesGridWidget()),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom Navigation Bar
              const Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: RepaintBoundary(child: AppBottomNavBar()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle premium badge widget
class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.9),
            AppColors.pink.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            'Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
