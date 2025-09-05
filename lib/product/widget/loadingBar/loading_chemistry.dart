import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/app_colors.dart';

/// A loading animation widget that uses the chemistry-themed Lottie animation
class LoadingChemistry extends StatelessWidget {
  final double size;
  final bool withContainer;

  const LoadingChemistry({
    super.key,
    this.size = 60,
    this.withContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget lottieAnimation = Lottie.asset(
      AssetConstants.instance.lottieLoadingChemistry,
      width: size,
      height: size,
      fit: BoxFit.cover,
      reverse: true,
      repeat: true,
    );

    if (!withContainer) {
      return lottieAnimation;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBlue, AppColors.background],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: lottieAnimation,
    );
  }
}
