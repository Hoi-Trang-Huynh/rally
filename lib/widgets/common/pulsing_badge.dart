import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A badge widget that displays a count with a subtle pulsing animation.
///
/// Used for unread message counts, notifications, etc.
/// Uses the theme's error color to match the notification badge styling.
class PulsingBadge extends StatefulWidget {
  /// The count to display.
  final String count;

  /// Optional background color. Defaults to theme's error color.
  final Color? backgroundColor;

  /// Optional text color. Defaults to theme's onError color.
  final Color? textColor;

  /// Whether to show the pulse animation.
  final bool animate;

  /// Creates a new [PulsingBadge].
  const PulsingBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.animate = true,
  });

  @override
  State<PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<PulsingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulsingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int? countValue = int.tryParse(widget.count);
    final String displayCount = countValue != null && countValue > 99 ? '99+' : widget.count;

    // Use error color to match notification badge
    final Color badgeColor = widget.backgroundColor ?? colorScheme.error;
    final Color textColor = widget.textColor ?? colorScheme.onError;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Pulse ring (animated)
        if (widget.animate)
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 8),
                      vertical: Responsive.h(context, 2),
                    ),
                    constraints: BoxConstraints(minWidth: Responsive.w(context, 20)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: <Color>[badgeColor, badgeColor.withValues(alpha: 0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      displayCount,
                      style: TextStyle(
                        color: Colors.transparent,
                        fontSize: Responsive.w(context, 10),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),

        // Main badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 8),
            vertical: Responsive.h(context, 2),
          ),
          constraints: BoxConstraints(minWidth: Responsive.w(context, 20)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: <Color>[badgeColor, badgeColor.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            displayCount,
            style: TextStyle(
              color: textColor,
              fontSize: Responsive.w(context, 10),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
