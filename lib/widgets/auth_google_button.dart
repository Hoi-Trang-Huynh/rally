import 'package:flutter/material.dart';

import 'visuals/scale_button.dart';

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

class _AuthGoogleButtonState extends State<AuthGoogleButton> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (widget.isLoading) {
      return const SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: null,
          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return ScaleButton(
      onTap: widget.onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: null, // Let ScaleButton handle taps
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline),
            disabledForegroundColor: colorScheme.onSurface, // Keep text valid
          ).copyWith(
            side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              return BorderSide(color: colorScheme.outline);
            }),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
    );
  }
}
