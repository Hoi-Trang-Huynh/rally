import 'package:flutter/material.dart';

/// A primary filled button used in auth screens.
///
/// Shows a loading indicator when [isLoading] is true.
class AuthPrimaryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFC04444),
          foregroundColor: Colors.white,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                )
                : Text(text),
      ),
    );
  }
}
