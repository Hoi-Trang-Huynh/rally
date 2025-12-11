import 'package:flutter/material.dart';

/// A back button widget used in auth screen flows.
class AuthBackButton extends StatelessWidget {
  /// Creates a new [AuthBackButton].
  const AuthBackButton({required this.label, required this.onPressed, super.key});

  /// The label text to show next to the back arrow.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
