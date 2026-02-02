import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/responsive.dart';

/// Data class for a speed dial menu item.
class SpeedDialItem {
  /// Creates a new [SpeedDialItem].
  const SpeedDialItem({required this.icon, required this.label, required this.onTap});

  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// Callback when the item is tapped.
  final VoidCallback onTap;
}

/// A full-screen overlay that displays speed dial menu items
/// fanning out upward from the action button position.
///
/// Includes a dimmed/blurred backdrop and staggered entry animations.
class SpeedDialOverlay extends StatefulWidget {
  /// Creates a new [SpeedDialOverlay].
  const SpeedDialOverlay({
    super.key,
    required this.items,
    required this.onClose,
    required this.anchorBottom,
  });

  /// The menu items to display.
  final List<SpeedDialItem> items;

  /// Called when the overlay should be dismissed.
  final VoidCallback onClose;

  /// Distance from bottom of screen to the center of the action button.
  final double anchorBottom;

  @override
  State<SpeedDialOverlay> createState() => _SpeedDialOverlayState();
}

class _SpeedDialOverlayState extends State<SpeedDialOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _backdropAnimation;
  late final Animation<double> _rotationAnimation;
  late final List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _backdropAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    );

    _itemAnimations = List<Animation<double>>.generate(
      widget.items.length,
      (int index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(0.15 + index * 0.15, 0.65 + index * 0.15, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double buttonSize = Responsive.w(context, 56);

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double backdropValue = _backdropAnimation.value;

          return Stack(
            children: <Widget>[
              // Dimmed + blurred backdrop
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3 * backdropValue, sigmaY: 3 * backdropValue),
                  child: Container(color: colorScheme.scrim.withValues(alpha: 0.4 * backdropValue)),
                ),
              ),

              // Menu items
              Positioned(
                bottom: widget.anchorBottom + buttonSize / 2 + Responsive.h(context, 20),
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(widget.items.length, (int index) {
                    // Reverse order: top item is last in list (farthest from button)
                    final int reversedIndex = widget.items.length - 1 - index;
                    final Animation<double> animation = _itemAnimations[reversedIndex];

                    return Padding(
                      padding: EdgeInsets.only(bottom: Responsive.h(context, 16)),
                      child: _SpeedDialMenuItem(
                        item: widget.items[reversedIndex],
                        animation: animation,
                        onDismiss: _dismiss,
                      ),
                    );
                  }),
                ),
              ),

              // Rotating close button (overlaps the real action button)
              Positioned(
                bottom: widget.anchorBottom - buttonSize / 2,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _dismiss();
                    },
                    child: Container(
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.25),
                            blurRadius: Responsive.w(context, 8),
                            offset: Offset(0, Responsive.h(context, 4)),
                          ),
                        ],
                      ),
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * pi / 4,
                        child: Icon(
                          Icons.add,
                          color: colorScheme.onPrimary,
                          size: Responsive.w(context, 46),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A single menu item in the speed dial.
class _SpeedDialMenuItem extends StatelessWidget {
  const _SpeedDialMenuItem({required this.item, required this.animation, required this.onDismiss});

  final SpeedDialItem item;
  final Animation<double> animation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double iconCircleSize = Responsive.w(context, 44);

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: Transform.scale(
              scale: 0.5 + 0.5 * animation.value.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onDismiss();
          item.onTap();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Label pill
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
                vertical: Responsive.h(context, 8),
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 12)),
            // Icon circle
            Container(
              width: iconCircleSize,
              height: iconCircleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.15),
                    blurRadius: Responsive.w(context, 6),
                    offset: Offset(0, Responsive.h(context, 2)),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                color: colorScheme.onPrimaryContainer,
                size: Responsive.w(context, 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
