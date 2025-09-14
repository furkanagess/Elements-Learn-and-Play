import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'animation_performance_monitor.dart';

/// Centralized animation management system for the entire app
/// Provides high-performance, memory-efficient animation controllers
/// with automatic lifecycle management and disposal
class AnimationManager {
  static final AnimationManager _instance = AnimationManager._internal();
  factory AnimationManager() => _instance;
  AnimationManager._internal();

  // Core animation controllers pool
  final Map<String, AnimationController> _controllerPool = {};
  final Map<String, Animation<double>> _doubleAnimationPool = {};
  final Map<String, Animation<Offset>> _offsetAnimationPool = {};
  final Map<String, TickerProvider> _tickerProviders = {};

  // Performance monitoring
  final AnimationPerformanceMonitor _performanceMonitor =
      AnimationPerformanceMonitor();

  // Animation configurations
  static const Map<AnimationType, AnimationConfig> _configs = {
    AnimationType.fadeIn: AnimationConfig(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOut,
      begin: 0.0,
      end: 1.0,
    ),
    AnimationType.fadeOut: AnimationConfig(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      begin: 1.0,
      end: 0.0,
    ),
    AnimationType.slideIn: AnimationConfig(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      begin: 0.0,
      end: 1.0,
      offsetBegin: Offset(0, 0.1),
      offsetEnd: Offset.zero,
    ),
    AnimationType.slideOut: AnimationConfig(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInCubic,
      begin: 1.0,
      end: 0.0,
      offsetBegin: Offset.zero,
      offsetEnd: Offset(0, -0.1),
    ),
    AnimationType.scaleIn: AnimationConfig(
      duration: Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      begin: 0.8,
      end: 1.0,
    ),
    AnimationType.scaleOut: AnimationConfig(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInBack,
      begin: 1.0,
      end: 0.8,
    ),
    AnimationType.bounceIn: AnimationConfig(
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
      begin: 0.0,
      end: 1.0,
    ),
    AnimationType.quickFade: AnimationConfig(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      begin: 0.0,
      end: 1.0,
    ),
    AnimationType.slowFade: AnimationConfig(
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      begin: 0.0,
      end: 1.0,
    ),
  };

  /// Creates or retrieves an animation controller for the given key
  AnimationController getController({
    required String key,
    required TickerProvider tickerProvider,
    Duration? customDuration,
    AnimationType? type,
  }) {
    // Dispose existing controller if ticker provider changed
    if (_tickerProviders[key] != tickerProvider) {
      disposeController(key);
    }

    if (!_controllerPool.containsKey(key)) {
      final config = type != null ? _configs[type] : null;
      final duration =
          customDuration ?? config?.duration ?? Duration(milliseconds: 400);

      final controller = AnimationController(
        duration: duration,
        vsync: tickerProvider,
      );

      // Add performance monitoring
      controller.addStatusListener((status) {
        if (status == AnimationStatus.forward ||
            status == AnimationStatus.reverse) {
          _performanceMonitor.recordAnimationStart(
            key,
            _getAnimationType(type),
          );
        } else if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _performanceMonitor.recordAnimationEnd(key);
        }
      });

      _controllerPool[key] = controller;
      _tickerProviders[key] = tickerProvider;
    }

    return _controllerPool[key]!;
  }

  /// Creates or retrieves a fade animation
  Animation<double> getFadeAnimation({
    required String key,
    required TickerProvider tickerProvider,
    AnimationType type = AnimationType.fadeIn,
    Duration? customDuration,
    Curve? customCurve,
    double? customBegin,
    double? customEnd,
  }) {
    final animationKey = '${key}_fade_${type.name}';

    if (!_doubleAnimationPool.containsKey(animationKey)) {
      final controller = getController(
        key: '${key}_controller',
        tickerProvider: tickerProvider,
        customDuration: customDuration,
        type: type,
      );

      final config = _configs[type]!;
      final begin = customBegin ?? config.begin;
      final end = customEnd ?? config.end;
      final curve = customCurve ?? config.curve;

      _doubleAnimationPool[animationKey] = Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: controller, curve: curve));
    }

    return _doubleAnimationPool[animationKey]!;
  }

  /// Creates or retrieves a slide animation
  Animation<Offset> getSlideAnimation({
    required String key,
    required TickerProvider tickerProvider,
    AnimationType type = AnimationType.slideIn,
    Duration? customDuration,
    Curve? customCurve,
    Offset? customBegin,
    Offset? customEnd,
  }) {
    final animationKey = '${key}_slide_${type.name}';

    if (!_offsetAnimationPool.containsKey(animationKey)) {
      final controller = getController(
        key: '${key}_controller',
        tickerProvider: tickerProvider,
        customDuration: customDuration,
        type: type,
      );

      final config = _configs[type]!;
      final begin = customBegin ?? config.offsetBegin ?? Offset.zero;
      final end = customEnd ?? config.offsetEnd ?? Offset.zero;
      final curve = customCurve ?? config.curve;

      _offsetAnimationPool[animationKey] = Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: controller, curve: curve));
    }

    return _offsetAnimationPool[animationKey]!;
  }

  /// Creates or retrieves a scale animation
  Animation<double> getScaleAnimation({
    required String key,
    required TickerProvider tickerProvider,
    AnimationType type = AnimationType.scaleIn,
    Duration? customDuration,
    Curve? customCurve,
    double? customBegin,
    double? customEnd,
  }) {
    final animationKey = '${key}_scale_${type.name}';

    if (!_doubleAnimationPool.containsKey(animationKey)) {
      final controller = getController(
        key: '${key}_controller',
        tickerProvider: tickerProvider,
        customDuration: customDuration,
        type: type,
      );

      final config = _configs[type]!;
      final begin = customBegin ?? config.begin;
      final end = customEnd ?? config.end;
      final curve = customCurve ?? config.curve;

      _doubleAnimationPool[animationKey] = Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: controller, curve: curve));
    }

    return _doubleAnimationPool[animationKey]!;
  }

  /// Starts an animation
  Future<void> startAnimation(String key, {AnimationType? type}) async {
    final controllerKey = '${key}_controller';
    final controller = _controllerPool[controllerKey];

    if (controller != null) {
      if (type == AnimationType.fadeOut ||
          type == AnimationType.slideOut ||
          type == AnimationType.scaleOut) {
        await controller.reverse();
      } else {
        await controller.forward();
      }
    }
  }

  /// Stops an animation
  void stopAnimation(String key) {
    final controllerKey = '${key}_controller';
    final controller = _controllerPool[controllerKey];
    controller?.stop();
  }

  /// Resets an animation to initial state
  void resetAnimation(String key) {
    final controllerKey = '${key}_controller';
    final controller = _controllerPool[controllerKey];
    controller?.reset();
  }

  /// Disposes a specific controller and its animations
  void disposeController(String key) {
    final controllerKey = '${key}_controller';
    final controller = _controllerPool.remove(controllerKey);
    controller?.dispose();

    _tickerProviders.remove(key);

    // Remove related animations from both pools
    _doubleAnimationPool.removeWhere(
      (animationKey, _) => animationKey.startsWith(key),
    );
    _offsetAnimationPool.removeWhere(
      (animationKey, _) => animationKey.startsWith(key),
    );
  }

  /// Disposes all controllers and animations
  void disposeAll() {
    for (final controller in _controllerPool.values) {
      controller.dispose();
    }
    _controllerPool.clear();
    _doubleAnimationPool.clear();
    _offsetAnimationPool.clear();
    _tickerProviders.clear();
  }

  /// Gets animation status
  AnimationStatus? getAnimationStatus(String key) {
    final controllerKey = '${key}_controller';
    return _controllerPool[controllerKey]?.status;
  }

  /// Checks if animation is running
  bool isAnimationRunning(String key) {
    final status = getAnimationStatus(key);
    return status == AnimationStatus.forward ||
        status == AnimationStatus.reverse;
  }

  /// Gets animation value
  double? getAnimationValue(String key, {AnimationType? type}) {
    final animationKey = '${key}_fade_${type?.name ?? 'fadeIn'}';
    final animation = _doubleAnimationPool[animationKey];
    return animation?.value;
  }

  /// Get performance monitor
  AnimationPerformanceMonitor get performanceMonitor => _performanceMonitor;

  /// Start performance monitoring
  void startPerformanceMonitoring() {
    _performanceMonitor.startMonitoring();
  }

  /// Stop performance monitoring
  void stopPerformanceMonitoring() {
    _performanceMonitor.stopMonitoring();
  }

  /// Get performance summary
  PerformanceSummary getPerformanceSummary() {
    return _performanceMonitor.getSummary();
  }

  /// Helper method to convert AnimationType to monitoring type
  MonitoringAnimationType _getAnimationType(AnimationType? type) {
    if (type == null) return MonitoringAnimationType.custom;

    switch (type) {
      case AnimationType.fadeIn:
      case AnimationType.fadeOut:
      case AnimationType.quickFade:
      case AnimationType.slowFade:
        return MonitoringAnimationType.fade;
      case AnimationType.slideIn:
      case AnimationType.slideOut:
        return MonitoringAnimationType.slide;
      case AnimationType.scaleIn:
      case AnimationType.scaleOut:
        return MonitoringAnimationType.scale;
      case AnimationType.bounceIn:
        return MonitoringAnimationType.custom;
    }
  }
}

/// Animation types available in the system
enum AnimationType {
  fadeIn,
  fadeOut,
  slideIn,
  slideOut,
  scaleIn,
  scaleOut,
  bounceIn,
  quickFade,
  slowFade,
}

/// Configuration for different animation types
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  final Offset? offsetBegin;
  final Offset? offsetEnd;

  const AnimationConfig({
    required this.duration,
    required this.curve,
    required this.begin,
    required this.end,
    this.offsetBegin,
    this.offsetEnd,
  });
}
