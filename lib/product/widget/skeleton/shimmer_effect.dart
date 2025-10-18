import 'package:flutter/material.dart';

/// Modern shimmer effect for skeleton loading
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Enhanced shimmer effect with multiple colors
class MultiColorShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color> colors;

  const MultiColorShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.colors = const [
      Color(0xFFE0E0E0),
      Color(0xFFF0F0F0),
      Color(0xFFE8E8E8),
      Color(0xFFF0F0F0),
      Color(0xFFE0E0E0),
    ],
  });

  @override
  State<MultiColorShimmerEffect> createState() =>
      _MultiColorShimmerEffectState();
}

class _MultiColorShimmerEffectState extends State<MultiColorShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: widget.colors,
              stops: List.generate(
                widget.colors.length,
                (index) => index / (widget.colors.length - 1),
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Pulse shimmer effect for loading indicators
class PulseShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final double maxOpacity;

  const PulseShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minOpacity = 0.3,
    this.maxOpacity = 1.0,
  });

  @override
  State<PulseShimmerEffect> createState() => _PulseShimmerEffectState();
}

class _PulseShimmerEffectState extends State<PulseShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: widget.minOpacity, end: widget.maxOpacity)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: widget.child);
      },
    );
  }
}
