import 'package:elements_app/product/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: appBarTheme(),
      scaffoldBackgroundColor: AppColors.background,
      iconTheme: iconTheme(),
      floatingActionButtonTheme: floatingActionButtonTheme(),
    );
  }

  static FloatingActionButtonThemeData floatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.purple,
      elevation: 5,
    );
  }

  static IconThemeData iconTheme() {
    return const IconThemeData(size: 30);
  }

  static AppBarTheme appBarTheme() {
    return const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      centerTitle: true,
    );
  }
}
