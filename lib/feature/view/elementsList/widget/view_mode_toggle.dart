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
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.steelBlue.withValues(alpha: 0.2),
                AppColors.darkBlue.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.steelBlue.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
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
        const SizedBox(height: 16),
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
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.turquoise.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: AppColors.turquoise.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.turquoise.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? AppColors.white.withValues(alpha: 0.7)
                      : AppColors.white.withValues(alpha: 0.8),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
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
