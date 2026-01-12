import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A background widget that renders animated gradient orbs.
class AnimatedBackground extends StatefulWidget {
  /// Creates a new [AnimatedBackground].
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Soft colors for the background blobs
    // Soft colors for the background blobs
    final Color primaryBlob = colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.15);
    final Color secondaryBlob = colorScheme.secondary.withValues(alpha: isDark ? 0.2 : 0.15);
    final Color tertiaryBlob = colorScheme.tertiary.withValues(alpha: isDark ? 0.2 : 0.15);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        return Stack(
          children: <Widget>[
            // Solid base background
            Container(color: colorScheme.surface),

            // Blob 1 (Top Left moving right)
            Positioned(
              top: -100 + (50 * sin(t * 2 * pi)),
              left: -50 + (30 * cos(t * 2 * pi)),
              child: _Blob(color: primaryBlob, size: Responsive.w(context, 400)),
            ),

            // Blob 2 (Center Right moving left/up)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4 + (40 * cos(t * 2 * pi)),
              right: -100 + (40 * sin(t * 2 * pi)),
              child: _Blob(color: secondaryBlob, size: Responsive.w(context, 350)),
            ),

            // Blob 3 (Bottom Left moving up)
            Positioned(
              bottom: -50 + (60 * sin(t * 2 * pi)),
              left: 20 + (30 * cos(t * 2 * pi)),
              child: _Blob(color: tertiaryBlob, size: Responsive.w(context, 300)),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(color: color, blurRadius: size / 2, spreadRadius: size / 4),
        ],
      ),
    );
  }
}
