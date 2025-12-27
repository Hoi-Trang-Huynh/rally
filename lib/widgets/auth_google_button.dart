import 'package:flutter/material.dart';

/// An outlined button for Google sign-in used in auth screens.
class AuthGoogleButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.g_mobiledata, size: 28),
                    const SizedBox(width: 8),
                    Text(text),
                  ],
                ),
      ),
    );
  }
}
