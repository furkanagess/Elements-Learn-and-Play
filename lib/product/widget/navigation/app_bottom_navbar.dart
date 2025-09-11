import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/favorites/favorites_view.dart';
import 'package:elements_app/feature/view/settings/settings_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesView(),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Favorites Button
          Expanded(
            child: _buildNavItem(
              context: context,
              icon: Icons.favorite_rounded,
              label: isTr ? TrAppStrings.favorites : EnAppStrings.favorites,
              onTap: () => _navigateToFavorites(context),
            ),
          ),

          // Divider
          Container(
            height: 24,
            width: 0.5,
            color: Colors.white.withValues(alpha: 0.2),
          ),

          // Settings Button
          Expanded(
            child: _buildNavItem(
              context: context,
              icon: Icons.settings_rounded,
              label: isTr ? TrAppStrings.settings : EnAppStrings.settings,
              onTap: () => _navigateToSettings(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
