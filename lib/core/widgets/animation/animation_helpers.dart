import 'package:flutter/material.dart';
import '../../services/animation/animation_manager.dart';

/// Helper functions and extensions for common animation operations
class AnimationHelpers {
  /// Creates a staggered animation for a list of widgets
  static List<Animation<double>> createStaggeredAnimations({
    required String baseKey,
    required TickerProvider tickerProvider,
    required int itemCount,
    Duration baseDuration = const Duration(milliseconds: 400),
    Duration staggerDelay = const Duration(milliseconds: 100),
    AnimationType type = AnimationType.fadeIn,
    Curve curve = Curves.easeOut,
  }) {
    final manager = AnimationManager();
    final animations = <Animation<double>>[];

    for (int i = 0; i < itemCount; i++) {
      final key = '${baseKey}_item_$i';
      final duration = Duration(
        milliseconds:
            baseDuration.inMilliseconds + (staggerDelay.inMilliseconds * i),
      );

      animations.add(
        manager.getFadeAnimation(
          key: key,
          tickerProvider: tickerProvider,
          type: type,
          customDuration: duration,
          customCurve: curve,
        ),
      );
    }

    return animations;
  }

  /// Creates a wave animation effect
  static List<Animation<double>> createWaveAnimations({
    required String baseKey,
    required TickerProvider tickerProvider,
    required int itemCount,
    Duration baseDuration = const Duration(milliseconds: 600),
    Duration waveDelay = const Duration(milliseconds: 150),
    AnimationType type = AnimationType.bounceIn,
  }) {
    final manager = AnimationManager();
    final animations = <Animation<double>>[];

    for (int i = 0; i < itemCount; i++) {
      final key = '${baseKey}_wave_$i';
      final delay = (i % 2 == 0) ? i ~/ 2 : (itemCount - 1 - i) ~/ 2;
      final duration = Duration(
        milliseconds:
            baseDuration.inMilliseconds + (waveDelay.inMilliseconds * delay),
      );

      animations.add(
        manager.getFadeAnimation(
          key: key,
          tickerProvider: tickerProvider,
          type: type,
          customDuration: duration,
        ),
      );
    }

    return animations;
  }

  /// Creates a breathing animation (pulse effect)
  static Animation<double> createBreathingAnimation({
    required String key,
    required TickerProvider tickerProvider,
    Duration duration = const Duration(seconds: 2),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    final manager = AnimationManager();
    final controller = manager.getController(
      key: key,
      tickerProvider: tickerProvider,
      customDuration: duration,
    );

    return Tween<double>(
      begin: minScale,
      end: maxScale,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  /// Creates a shake animation
  static Animation<Offset> createShakeAnimation({
    required String key,
    required TickerProvider tickerProvider,
    Duration duration = const Duration(milliseconds: 500),
    double intensity = 10.0,
  }) {
    final manager = AnimationManager();
    final controller = manager.getController(
      key: key,
      tickerProvider: tickerProvider,
      customDuration: duration,
    );

    return TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: Offset(-intensity, 0)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(-intensity, 0),
          end: Offset(intensity, 0),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(intensity, 0),
          end: Offset(-intensity, 0),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(-intensity, 0),
          end: Offset(intensity, 0),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(intensity, 0), end: Offset.zero),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
}

/// Extension methods for easier animation usage
extension AnimationExtensions on BuildContext {
  /// Gets the animation manager instance
  AnimationManager get animationManager => AnimationManager();

  /// Creates a fade animation for the current context
  Animation<double> createFadeAnimation({
    required String key,
    AnimationType type = AnimationType.fadeIn,
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    final tickerProvider = this
        .findAncestorStateOfType<TickerProviderStateMixin>();
    if (tickerProvider == null) {
      throw StateError('No TickerProvider found in widget tree');
    }

    return animationManager.getFadeAnimation(
      key: key,
      tickerProvider: tickerProvider,
      type: type,
      customDuration: duration,
      customCurve: curve,
      customBegin: begin,
      customEnd: end,
    );
  }

  /// Creates a slide animation for the current context
  Animation<Offset> createSlideAnimation({
    required String key,
    AnimationType type = AnimationType.slideIn,
    Duration? duration,
    Curve? curve,
    Offset? begin,
    Offset? end,
  }) {
    final tickerProvider = this
        .findAncestorStateOfType<TickerProviderStateMixin>();
    if (tickerProvider == null) {
      throw StateError('No TickerProvider found in widget tree');
    }

    return animationManager.getSlideAnimation(
      key: key,
      tickerProvider: tickerProvider,
      type: type,
      customDuration: duration,
      customCurve: curve,
      customBegin: begin,
      customEnd: end,
    );
  }

  /// Creates a scale animation for the current context
  Animation<double> createScaleAnimation({
    required String key,
    AnimationType type = AnimationType.scaleIn,
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    final tickerProvider = this
        .findAncestorStateOfType<TickerProviderStateMixin>();
    if (tickerProvider == null) {
      throw StateError('No TickerProvider found in widget tree');
    }

    return animationManager.getScaleAnimation(
      key: key,
      tickerProvider: tickerProvider,
      type: type,
      customDuration: duration,
      customCurve: curve,
      customBegin: begin,
      customEnd: end,
    );
  }
}

/// Widget builder for animated lists
class AnimatedListBuilder extends StatelessWidget {
  final List<Widget> children;
  final String animationKey;
  final AnimationType type;
  final Duration? duration;
  final Duration? staggerDelay;
  final Curve curve;
  final bool autoStart;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const AnimatedListBuilder({
    Key? key,
    required this.children,
    required this.animationKey,
    this.type = AnimationType.fadeIn,
    this.duration,
    this.staggerDelay,
    this.curve = Curves.easeOut,
    this.autoStart = true,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AnimatedListBuilderState(
      children: children,
      animationKey: animationKey,
      type: type,
      duration: duration,
      staggerDelay: staggerDelay,
      curve: curve,
      autoStart: autoStart,
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }
}

class _AnimatedListBuilderState extends StatefulWidget {
  final List<Widget> children;
  final String animationKey;
  final AnimationType type;
  final Duration? duration;
  final Duration? staggerDelay;
  final Curve curve;
  final bool autoStart;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const _AnimatedListBuilderState({
    required this.children,
    required this.animationKey,
    required this.type,
    this.duration,
    this.staggerDelay,
    required this.curve,
    required this.autoStart,
    required this.direction,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
  });

  @override
  State<_AnimatedListBuilderState> createState() =>
      __AnimatedListBuilderStateState();
}

class __AnimatedListBuilderStateState extends State<_AnimatedListBuilderState>
    with TickerProviderStateMixin {
  late List<Animation<double>> _animations;
  final AnimationManager _animationManager = AnimationManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animations = AnimationHelpers.createStaggeredAnimations(
      baseKey: widget.animationKey,
      tickerProvider: this,
      itemCount: widget.children.length,
      baseDuration: widget.duration ?? const Duration(milliseconds: 400),
      staggerDelay: widget.staggerDelay ?? const Duration(milliseconds: 100),
      type: widget.type,
      curve: widget.curve,
    );

    if (widget.autoStart) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (int i = 0; i < _animations.length; i++) {
      final controller = _animationManager.getController(
        key: '${widget.animationKey}_item_$i',
        tickerProvider: this,
      );
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.children.length; i++) {
      _animationManager.disposeController('${widget.animationKey}_item_$i');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: widget.direction,
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: List.generate(widget.children.length, (index) {
        return FadeTransition(
          opacity: _animations[index],
          child: widget.children[index],
        );
      }),
    );
  }
}
