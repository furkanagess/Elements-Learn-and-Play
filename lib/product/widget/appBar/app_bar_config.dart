import 'package:elements_app/product/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// AppBar theme configuration
enum AppBarVariant {
  elementsList,
  favorites,
  quiz,
  periodicTable,
  elementDetail,
  settings,
  info,
  help,
  groups,
  defaultTheme,
}

/// AppBar style configuration
enum AppBarStyle { gradient, solid, transparent }

/// AppBar configuration class
class AppBarConfig {
  final AppBarVariant theme;
  final AppBarStyle style;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const AppBarConfig({
    required this.theme,
    required this.style,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.gradientColors,
    this.flexibleSpace,
    this.bottom,
  });

  /// Get gradient colors based on theme
  List<Color> get themeGradientColors {
    switch (theme) {
      case AppBarVariant.elementsList:
        return [
          AppColors.darkBlue,
          AppColors.steelBlue.withValues(alpha: 0.95),
          AppColors.purple.withValues(alpha: 0.9),
        ];
      case AppBarVariant.favorites:
        return [
          AppColors.powderRed,
          AppColors.pink.withValues(alpha: 0.95),
          AppColors.purple.withValues(alpha: 0.9),
        ];
      case AppBarVariant.quiz:
        return [
          AppColors.glowGreen,
          AppColors.yellow.withValues(alpha: 0.95),
          AppColors.darkBlue.withValues(alpha: 0.9),
        ];
      case AppBarVariant.periodicTable:
        return [
          AppColors.purple,
          AppColors.pink.withValues(alpha: 0.9),
          AppColors.turquoise.withValues(alpha: 0.8),
        ];
      case AppBarVariant.elementDetail:
        return [AppColors.darkBlue, AppColors.steelBlue.withValues(alpha: 0.9)];
      case AppBarVariant.settings:
        return [
          AppColors.darkBlue,
          AppColors.steelBlue.withValues(alpha: 0.95),
        ];
      case AppBarVariant.info:
        return [
          AppColors.turquoise,
          AppColors.steelBlue.withValues(alpha: 0.9),
        ];
      case AppBarVariant.help:
        return [AppColors.yellow, AppColors.glowGreen.withValues(alpha: 0.9)];
      case AppBarVariant.groups:
        return [AppColors.pink, AppColors.purple.withValues(alpha: 0.9)];
      case AppBarVariant.defaultTheme:
        return [
          AppColors.darkBlue,
          AppColors.steelBlue.withValues(alpha: 0.95),
        ];
    }
  }

  /// Get background color based on theme
  Color get themeBackgroundColor {
    switch (theme) {
      case AppBarVariant.periodicTable:
        return AppColors.purple;
      case AppBarVariant.defaultTheme:
        return AppColors.darkBlue;
      default:
        return Colors.transparent;
    }
  }

  /// Get elevation based on style
  double get themeElevation {
    switch (style) {
      case AppBarStyle.gradient:
      case AppBarStyle.transparent:
        return 0;
      case AppBarStyle.solid:
        return 4;
    }
  }

  /// Create a copy with new values
  AppBarConfig copyWith({
    AppBarVariant? theme,
    AppBarStyle? style,
    String? title,
    String? subtitle,
    IconData? icon,
    Widget? leading,
    List<Widget>? actions,
    bool? showBackButton,
    bool? centerTitle,
    double? elevation,
    Color? backgroundColor,
    List<Color>? gradientColors,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
  }) {
    return AppBarConfig(
      theme: theme ?? this.theme,
      style: style ?? this.style,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      leading: leading ?? this.leading,
      actions: actions ?? this.actions,
      showBackButton: showBackButton ?? this.showBackButton,
      centerTitle: centerTitle ?? this.centerTitle,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientColors: gradientColors ?? this.gradientColors,
      flexibleSpace: flexibleSpace ?? this.flexibleSpace,
      bottom: bottom ?? this.bottom,
    );
  }
}

/// Predefined AppBar configurations
class AppBarConfigs {
  static AppBarConfig elementsList({
    required String title,
    List<Widget>? actions,
    Widget? flexibleSpace,
  }) {
    return AppBarConfig(
      theme: AppBarVariant.elementsList,
      style: AppBarStyle.gradient,
      title: title,
      actions: actions,
      flexibleSpace: flexibleSpace,
    );
  }

  static AppBarConfig favorites({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBarConfig(
      theme: AppBarVariant.favorites,
      style: AppBarStyle.gradient,
      title: title,
      icon: Icons.favorite,
      actions: actions,
    );
  }

  static AppBarConfig quiz({required String title, List<Widget>? actions}) {
    return AppBarConfig(
      theme: AppBarVariant.quiz,
      style: AppBarStyle.gradient,
      title: title,
      icon: Icons.quiz,
      actions: actions,
    );
  }

  static AppBarConfig periodicTable({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBarConfig(
      theme: AppBarVariant.periodicTable,
      style: AppBarStyle.gradient,
      title: title,
      actions: actions,
    );
  }

  static AppBarConfig elementDetail({
    required String title,
    Color? backgroundColor,
    List<Widget>? actions,
  }) {
    return AppBarConfig(
      theme: AppBarVariant.elementDetail,
      style: AppBarStyle.gradient,
      title: title,
      backgroundColor: backgroundColor,
      actions: actions,
    );
  }

  static AppBarConfig settings({required String title, List<Widget>? actions}) {
    return AppBarConfig(
      theme: AppBarVariant.settings,
      style: AppBarStyle.gradient,
      title: title,
      icon: Icons.settings,
      actions: actions,
    );
  }

  static AppBarConfig info({required String title, List<Widget>? actions}) {
    return AppBarConfig(
      theme: AppBarVariant.info,
      style: AppBarStyle.gradient,
      title: title,
      icon: Icons.info,
      actions: actions,
    );
  }

  static AppBarConfig help({required String title, List<Widget>? actions}) {
    return AppBarConfig(
      theme: AppBarVariant.help,
      style: AppBarStyle.gradient,
      title: title,
      icon: Icons.help,
      actions: actions,
    );
  }

  static AppBarConfig groups({required String title, List<Widget>? actions}) {
    return AppBarConfig(
      theme: AppBarVariant.groups,
      style: AppBarStyle.gradient,
      title: title,
      icon: Icons.category,
      actions: actions,
    );
  }

  static AppBarConfig custom({
    required AppBarVariant theme,
    required AppBarStyle style,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? leading,
    List<Widget>? actions,
    bool showBackButton = true,
    bool centerTitle = false,
    double? elevation,
    Color? backgroundColor,
    List<Color>? gradientColors,
    Widget? flexibleSpace,
    PreferredSizeWidget? bottom,
  }) {
    return AppBarConfig(
      theme: theme,
      style: style,
      title: title,
      subtitle: subtitle,
      icon: icon,
      leading: leading,
      actions: actions,
      showBackButton: showBackButton,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      gradientColors: gradientColors,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
    );
  }
}
