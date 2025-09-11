import 'package:flutter/material.dart';
import 'package:elements_app/product/constants/app_colors.dart';

class ModernBackButton extends StatelessWidget {
  final bool navigateToHome;

  const ModernBackButton({
    super.key,
    this.navigateToHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
        onPressed: () {
          if (navigateToHome) {
            // Pop until we reach the root/home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            // Normal pop behavior
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
