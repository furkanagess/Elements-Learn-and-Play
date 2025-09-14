import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Toggle component for switching between list and grid view modes
class ViewModeToggle extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggle;

  const ViewModeToggle({
    super.key,
    required this.isGridView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.glowGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // List View Button
              Expanded(
                child: _buildToggleButton(
                  context: context,
                  icon: Icons.view_list,
                  isActive: !isGridView,
                  onTap: isGridView ? onToggle : null,
                ),
              ),
              // Grid View Button
              Expanded(
                child: _buildToggleButton(
                  context: context,
                  icon: Icons.grid_view,
                  isActive: isGridView,
                  onTap: !isGridView ? onToggle : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Banner Ads
        const BannerAdsWidget(
          margin: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final label = icon == Icons.view_list
        ? (isTr ? 'Liste' : 'List')
        : (isTr ? 'Tablo' : 'Table');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive ? AppColors.glowGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.darkBlue
                    : AppColors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.darkBlue
                      : AppColors.white.withValues(alpha: 0.7),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
