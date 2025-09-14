import 'package:flutter/material.dart';
import 'animation_manager.dart';

/// High-performance wrapper for AnimationController with automatic lifecycle management
/// Provides a clean API for common animation operations
class AnimationControllerWrapper {
  final String _key;
  final TickerProvider _tickerProvider;
  final AnimationManager _manager;

  AnimationControllerWrapper({
    required String key,
    required TickerProvider tickerProvider,
    AnimationManager? manager,
  }) : _key = key,
       _tickerProvider = tickerProvider,
       _manager = manager ?? AnimationManager();

  /// Gets the underlying controller
  AnimationController get controller =>
      _manager.getController(key: _key, tickerProvider: _tickerProvider);

  /// Gets fade animation
  Animation<double> getFadeAnimation({
    AnimationType type = AnimationType.fadeIn,
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return _manager.getFadeAnimation(
      key: _key,
      tickerProvider: _tickerProvider,
      type: type,
      customDuration: duration,
      customCurve: curve,
      customBegin: begin,
      customEnd: end,
    );
  }

  /// Gets slide animation
  Animation<Offset> getSlideAnimation({
    AnimationType type = AnimationType.slideIn,
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    return _manager.getSlideAnimation(
      key: _key,
      tickerProvider: _tickerProvider,
      type: type,
      customDuration: duration,
      customCurve: curve,
      customBegin: begin,
      customEnd: end,
    );
  }

  /// Gets scale animation
  Animation<double> getScaleAnimation({
    AnimationType type = AnimationType.scaleIn,
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return _manager.getScaleAnimation(
      key: _key,
      tickerProvider: _tickerProvider,
      type: type,
      customDuration: duration,
      customCurve: curve,
      customBegin: begin,
      customEnd: end,
    );
  }

  /// Starts animation forward
  Future<void> forward({AnimationType? type}) async {
    await _manager.startAnimation(_key, type: type);
  }

  /// Starts animation reverse
  Future<void> reverse({AnimationType? type}) async {
    await _manager.startAnimation(_key, type: type ?? AnimationType.fadeOut);
  }

  /// Stops animation
  void stop() {
    _manager.stopAnimation(_key);
  }

  /// Resets animation
  void reset() {
    _manager.resetAnimation(_key);
  }

  /// Gets animation status
  AnimationStatus? get status => _manager.getAnimationStatus(_key);

  /// Checks if animation is running
  bool get isRunning => _manager.isAnimationRunning(_key);

  /// Gets current animation value
  double? get value => _manager.getAnimationValue(_key);

  /// Disposes the controller
  void dispose() {
    _manager.disposeController(_key);
  }
}

/// Mixin for easy animation integration in StatefulWidgets
mixin AnimationControllerMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  final Map<String, AnimationControllerWrapper> _controllers = {};
  final AnimationManager _animationManager = AnimationManager();

  /// Gets or creates an animation controller wrapper
  AnimationControllerWrapper getAnimationController(String key) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = AnimationControllerWrapper(
        key: key,
        tickerProvider: this,
        manager: _animationManager,
      );
    }
    return _controllers[key]!;
  }

  /// Gets fade animation with automatic controller management
  Animation<double> getFadeAnimation({
    required String key,
    AnimationType type = AnimationType.fadeIn,
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return getAnimationController(key).getFadeAnimation(
      type: type,
      duration: duration,
      curve: curve,
      begin: begin,
      end: end,
    );
  }

  /// Gets slide animation with automatic controller management
  Animation<Offset> getSlideAnimation({
    required String key,
    AnimationType type = AnimationType.slideIn,
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    return getAnimationController(key).getSlideAnimation(
      type: type,
      duration: duration,
      curve: curve,
      begin: begin,
      end: end,
    );
  }

  /// Gets scale animation with automatic controller management
  Animation<double> getScaleAnimation({
    required String key,
    AnimationType type = AnimationType.scaleIn,
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return getAnimationController(key).getScaleAnimation(
      type: type,
      duration: duration,
      curve: curve,
      begin: begin,
      end: end,
    );
  }

  /// Starts animation
  Future<void> startAnimation(String key, {AnimationType? type}) async {
    await getAnimationController(key).forward(type: type);
  }

  /// Stops animation
  void stopAnimation(String key) {
    getAnimationController(key).stop();
  }

  /// Resets animation
  void resetAnimation(String key) {
    getAnimationController(key).reset();
  }

  /// Gets animation status
  AnimationStatus? getAnimationStatus(String key) {
    return getAnimationController(key).status;
  }

  /// Checks if animation is running
  bool isAnimationRunning(String key) {
    return getAnimationController(key).isRunning;
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}
