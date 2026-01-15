import 'dart:ui';

import 'package:flutter/material.dart';

/// A container that applies a glassmorphism effect (blur + translucency).
class GlassContainer extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The amount of gaussian blur to apply.
  final double blur;

  /// The opacity of the glass effect.
  final double opacity;

  /// The border radius.
  final BorderRadius? borderRadius;

  /// The border color.
  final Color? borderColor;

  /// Optional shadows for depth.
  final List<BoxShadow>? shadows;

  /// Creates a [GlassContainer].
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.borderColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(borderRadius: effectiveBorderRadius, boxShadow: shadows),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: opacity),
              borderRadius: effectiveBorderRadius,
              border: Border.all(
                color: borderColor ?? colorScheme.outline.withValues(alpha: 0.2),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
