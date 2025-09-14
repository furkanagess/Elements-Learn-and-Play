import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/appBar/app_bar_config.dart';
import 'package:flutter/material.dart';

/// Unified AppBar component that handles all AppBar variations in the app
class UnifiedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarConfig config;

  const UnifiedAppBar({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _getBackgroundColor(),
      flexibleSpace: _buildFlexibleSpace(),
      leading: _buildLeading(),
      title: _buildTitle(),
      actions: config.actions,
      centerTitle: config.centerTitle,
      elevation: _getElevation(),
      bottom: config.bottom,
    );
  }

  /// Build flexible space based on style
  Widget? _buildFlexibleSpace() {
    if (config.flexibleSpace != null) {
      return config.flexibleSpace;
    }

    switch (config.style) {
      case AppBarStyle.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(),
            ),
          ),
        );
      case AppBarStyle.solid:
        return null;
      case AppBarStyle.transparent:
        return null;
    }
  }

  /// Build leading widget
  Widget? _buildLeading() {
    if (config.leading != null) {
      return config.leading;
    }

    if (config.showBackButton) {
      return const ModernBackButton();
    }

    return null;
  }

  /// Build title widget
  Widget _buildTitle() {
    if (config.icon != null) {
      return _buildTitleWithIcon();
    }

    if (config.subtitle != null) {
      return _buildTitleWithSubtitle();
    }

    return Text(
      config.title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Build title with icon
  Widget _buildTitleWithIcon() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(config.icon!, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          config.title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build title with subtitle
  Widget _buildTitleWithSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          config.title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (config.subtitle != null)
          Text(
            config.subtitle!,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  /// Get background color
  Color _getBackgroundColor() {
    if (config.backgroundColor != null) {
      return config.backgroundColor!;
    }

    switch (config.style) {
      case AppBarStyle.gradient:
      case AppBarStyle.transparent:
        return Colors.transparent;
      case AppBarStyle.solid:
        return config.themeBackgroundColor;
    }
  }

  /// Get gradient colors
  List<Color> _getGradientColors() {
    if (config.gradientColors != null) {
      return config.gradientColors!;
    }

    return config.themeGradientColors;
  }

  /// Get elevation
  double _getElevation() {
    if (config.elevation != null) {
      return config.elevation!;
    }

    return config.themeElevation;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Extension for easy AppBar creation
extension AppBarConfigExtension on AppBarConfig {
  /// Convert config to UnifiedAppBar
  UnifiedAppBar toAppBar() {
    return UnifiedAppBar(config: this);
  }
}
