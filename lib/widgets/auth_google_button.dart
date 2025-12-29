import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An outlined button for Google sign-in used in auth screens.
///
/// Includes bounce animation and haptic feedback.
class AuthGoogleButton extends StatefulWidget {
  /// Creates a new [AuthGoogleButton].
  const AuthGoogleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  /// The button text.
  final String text;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state (disables it).
  final bool isLoading;

  @override
  State<AuthGoogleButton> createState() => _AuthGoogleButtonState();
}

class _AuthGoogleButtonState extends State<AuthGoogleButton> with SingleTickerProviderStateMixin {
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
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : () {}, // Handled by GestureDetector
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Center(
              child:
                  widget.isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Improved Google Icon (colored) or keep simple? Keeping simple for now but using FontAwesome usually better.
                          // Using simple 'G' text or just icon for now.
                          Image.asset(
                            'assets/images/google_logo.png',
                            height: 24,
                            width: 24,
                            errorBuilder:
                                (BuildContext context, Object error, StackTrace? stackTrace) =>
                                    const Icon(Icons.g_mobiledata, size: 28),
                          ),
                          const SizedBox(width: 8),
                          Text(widget.text),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
