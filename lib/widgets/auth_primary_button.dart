import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A primary filled button used in auth screens.
///
/// Shows a loading indicator when [isLoading] is true.
/// Includes bounce animation and haptic feedback.
class AuthPrimaryButton extends StatefulWidget {
  /// Creates a new [AuthPrimaryButton].
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  /// The button text.
  final String text;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether to show loading indicator.
  final bool isLoading;

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isLoading || widget.onPressed == null) return;
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (widget.isLoading || widget.onPressed == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: 1.0 - _controller.value, child: child);
      },
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: widget.isLoading ? null : () {}, // Handled by GestureDetector
          style: FilledButton.styleFrom(
            // Disable default splash to avoid conflict with scale anim if desired,
            // but keeping it adds to the effect.
          ).copyWith(
            // OverlayColor hack to disable internal inkwell if we rely purely on our gesture
            // overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Center(
              child:
                  widget.isLoading
                      ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                      : Text(widget.text),
            ),
          ),
        ),
      ),
    );
  }
}
