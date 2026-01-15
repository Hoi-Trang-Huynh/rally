import 'package:flutter/material.dart';

/// A widget that displays a shimmer effect for loading states.
class ShimmerLoading extends StatefulWidget {
  /// The width of the shimmer container.
  final double width;

  /// The height of the shimmer container.
  final double height;

  /// The border radius of the shimmer container.
  final double borderRadius;

  /// Creates a [ShimmerLoading] widget.
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color baseColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final Color highlightColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[baseColor, highlightColor, baseColor],
              stops: <double>[0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
