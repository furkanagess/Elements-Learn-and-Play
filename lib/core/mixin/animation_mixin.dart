import 'package:flutter/material.dart';
import '../services/animation/animation_controller_wrapper.dart';

/// Legacy animation mixin - DEPRECATED
/// Use AnimationControllerMixin instead for better performance and memory management
@Deprecated('Use AnimationControllerMixin instead')
mixin AnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: slideController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    fadeController.forward();
    slideController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
  }

  // Helper methods for common animation widgets
  Widget fadeInWidget({required Widget child}) {
    return FadeTransition(opacity: fadeAnimation, child: child);
  }

  Widget slideInWidget({required Widget child}) {
    return SlideTransition(position: slideAnimation, child: child);
  }

  Widget fadeSlideInWidget({required Widget child}) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }
}
