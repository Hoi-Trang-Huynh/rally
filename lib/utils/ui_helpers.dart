import 'package:flutter/material.dart';

/// Shared UI helper functions.

/// Shows an error snackbar with the given message.
void showErrorSnackBar(BuildContext context, String message) {
  _showModernSnackBar(
    context,
    message,
    backgroundColor: Theme.of(context).colorScheme.errorContainer,
    textColor: Theme.of(context).colorScheme.onErrorContainer,
    icon: Icons.error_outline,
  );
}

/// Shows a success snackbar with the given message.
void showSuccessSnackBar(BuildContext context, String message) {
  _showModernSnackBar(
    context,
    message,
    backgroundColor: Colors.green.shade600,
    textColor: Colors.white,
    icon: Icons.check_circle_outline,
  );
}

/// Shows an info snackbar with the given message.
void showInfoSnackBar(BuildContext context, String message) {
  _showModernSnackBar(
    context,
    message,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    textColor: Theme.of(context).colorScheme.onSurfaceVariant,
    icon: Icons.info_outline,
  );
}

/// Internal helper to show a consistent modern snackbar.
void _showModernSnackBar(
  BuildContext context,
  String message, {
  required Color backgroundColor,
  required Color textColor,
  required IconData icon,
}) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: backgroundColor,
        elevation: 4,
        content: Row(
          children: <Widget>[
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
}
