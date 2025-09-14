import 'package:flutter/material.dart';
import '../../services/animation/animation_manager.dart';

/// High-performance, reusable fade animation widget
/// Automatically manages animation lifecycle and provides smooth transitions
class AnimatedFadeWidget extends StatefulWidget {
  final Widget child;
  final String animationKey;
  final AnimationType type;
  final Duration? duration;
  final Curve? curve;
  final double? beginOpacity;
  final double? endOpacity;
  final bool autoStart;
  final bool maintainState;
  final VoidCallback? onAnimationComplete;
  final VoidCallback? onAnimationStart;

  const AnimatedFadeWidget({
    Key? key,
    required this.child,
    required this.animationKey,
    this.type = AnimationType.fadeIn,
    this.duration,
    this.curve,
    this.beginOpacity,
    this.endOpacity,
    this.autoStart = true,
    this.maintainState = true,
    this.onAnimationComplete,
    this.onAnimationStart,
  }) : super(key: key);

  @override
  State<AnimatedFadeWidget> createState() => _AnimatedFadeWidgetState();
}

class _AnimatedFadeWidgetState extends State<AnimatedFadeWidget>
    with TickerProviderStateMixin {
  late Animation<double> _fadeAnimation;
  late AnimationController _controller;
  final AnimationManager _animationManager = AnimationManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = _animationManager.getController(
      key: widget.animationKey,
      tickerProvider: this,
      customDuration: widget.duration,
      type: widget.type,
    );

    _fadeAnimation = _animationManager.getFadeAnimation(
      key: widget.animationKey,
      tickerProvider: this,
      type: widget.type,
      customDuration: widget.duration,
      customCurve: widget.curve,
      customBegin: widget.beginOpacity,
      customEnd: widget.endOpacity,
    );

    _controller.addStatusListener(_onAnimationStatusChanged);

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    } else if (status == AnimationStatus.forward) {
      widget.onAnimationStart?.call();
    }
  }

  void _startAnimation() {
    if (widget.type == AnimationType.fadeOut) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFadeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationKey != widget.animationKey ||
        oldWidget.type != widget.type ||
        oldWidget.duration != widget.duration) {
      _controller.removeStatusListener(_onAnimationStatusChanged);
      _initializeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _animationManager.disposeController(widget.animationKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.maintainState
          ? widget.child
          : AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return _fadeAnimation.value > 0.01
                    ? widget.child
                    : const SizedBox.shrink();
              },
            ),
    );
  }
}

/// Slide animation widget with fade effect
class AnimatedSlideFadeWidget extends StatefulWidget {
  final Widget child;
  final String animationKey;
  final AnimationType type;
  final Duration? duration;
  final Curve? curve;
  final Offset? slideBegin;
  final Offset? slideEnd;
  final double? fadeBegin;
  final double? fadeEnd;
  final bool autoStart;
  final bool maintainState;
  final VoidCallback? onAnimationComplete;
  final VoidCallback? onAnimationStart;

  const AnimatedSlideFadeWidget({
    Key? key,
    required this.child,
    required this.animationKey,
    this.type = AnimationType.slideIn,
    this.duration,
    this.curve,
    this.slideBegin,
    this.slideEnd,
    this.fadeBegin,
    this.fadeEnd,
    this.autoStart = true,
    this.maintainState = true,
    this.onAnimationComplete,
    this.onAnimationStart,
  }) : super(key: key);

  @override
  State<AnimatedSlideFadeWidget> createState() =>
      _AnimatedSlideFadeWidgetState();
}

class _AnimatedSlideFadeWidgetState extends State<AnimatedSlideFadeWidget>
    with TickerProviderStateMixin {
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _controller;
  final AnimationManager _animationManager = AnimationManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // Use separate controllers for slide and fade animations
    _controller = _animationManager.getController(
      key: '${widget.animationKey}_slide',
      tickerProvider: this,
      customDuration: widget.duration,
      type: widget.type,
    );

    _slideAnimation = _animationManager.getSlideAnimation(
      key: '${widget.animationKey}_slide',
      tickerProvider: this,
      type: widget.type,
      customDuration: widget.duration,
      customCurve: widget.curve,
      customBegin: widget.slideBegin,
      customEnd: widget.slideEnd,
    );

    _fadeAnimation = _animationManager.getFadeAnimation(
      key: '${widget.animationKey}_fade',
      tickerProvider: this,
      type: widget.type,
      customDuration: widget.duration,
      customCurve: widget.curve,
      customBegin: widget.fadeBegin,
      customEnd: widget.fadeEnd,
    );

    _controller.addStatusListener(_onAnimationStatusChanged);

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    } else if (status == AnimationStatus.forward) {
      widget.onAnimationStart?.call();
    }
  }

  void _startAnimation() {
    if (widget.type == AnimationType.slideOut) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedSlideFadeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationKey != widget.animationKey ||
        oldWidget.type != widget.type ||
        oldWidget.duration != widget.duration) {
      _controller.removeStatusListener(_onAnimationStatusChanged);
      _initializeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _animationManager.disposeController('${widget.animationKey}_slide');
    _animationManager.disposeController('${widget.animationKey}_fade');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.maintainState
            ? widget.child
            : AnimatedBuilder(
                animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
                builder: (context, child) {
                  return _fadeAnimation.value > 0.01
                      ? widget.child
                      : const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}

/// Scale animation widget with fade effect
class AnimatedScaleFadeWidget extends StatefulWidget {
  final Widget child;
  final String animationKey;
  final AnimationType type;
  final Duration? duration;
  final Curve? curve;
  final double? scaleBegin;
  final double? scaleEnd;
  final double? fadeBegin;
  final double? fadeEnd;
  final bool autoStart;
  final bool maintainState;
  final VoidCallback? onAnimationComplete;
  final VoidCallback? onAnimationStart;

  const AnimatedScaleFadeWidget({
    Key? key,
    required this.child,
    required this.animationKey,
    this.type = AnimationType.scaleIn,
    this.duration,
    this.curve,
    this.scaleBegin,
    this.scaleEnd,
    this.fadeBegin,
    this.fadeEnd,
    this.autoStart = true,
    this.maintainState = true,
    this.onAnimationComplete,
    this.onAnimationStart,
  }) : super(key: key);

  @override
  State<AnimatedScaleFadeWidget> createState() =>
      _AnimatedScaleFadeWidgetState();
}

class _AnimatedScaleFadeWidgetState extends State<AnimatedScaleFadeWidget>
    with TickerProviderStateMixin {
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _controller;
  final AnimationManager _animationManager = AnimationManager();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // Use separate controllers for scale and fade animations
    _controller = _animationManager.getController(
      key: '${widget.animationKey}_scale',
      tickerProvider: this,
      customDuration: widget.duration,
      type: widget.type,
    );

    _scaleAnimation = _animationManager.getScaleAnimation(
      key: '${widget.animationKey}_scale',
      tickerProvider: this,
      type: widget.type,
      customDuration: widget.duration,
      customCurve: widget.curve,
      customBegin: widget.scaleBegin,
      customEnd: widget.scaleEnd,
    );

    _fadeAnimation = _animationManager.getFadeAnimation(
      key: '${widget.animationKey}_fade',
      tickerProvider: this,
      type: widget.type,
      customDuration: widget.duration,
      customCurve: widget.curve,
      customBegin: widget.fadeBegin,
      customEnd: widget.fadeEnd,
    );

    _controller.addStatusListener(_onAnimationStatusChanged);

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    } else if (status == AnimationStatus.forward) {
      widget.onAnimationStart?.call();
    }
  }

  void _startAnimation() {
    if (widget.type == AnimationType.scaleOut) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedScaleFadeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationKey != widget.animationKey ||
        oldWidget.type != widget.type ||
        oldWidget.duration != widget.duration) {
      _controller.removeStatusListener(_onAnimationStatusChanged);
      _initializeAnimation();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _animationManager.disposeController('${widget.animationKey}_scale');
    _animationManager.disposeController('${widget.animationKey}_fade');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.maintainState
            ? widget.child
            : AnimatedBuilder(
                animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
                builder: (context, child) {
                  return _fadeAnimation.value > 0.01
                      ? widget.child
                      : const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}
