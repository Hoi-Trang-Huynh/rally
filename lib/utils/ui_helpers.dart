import 'package:flutter/material.dart';
import 'package:rally/themes/app_theme_extension.dart';
import 'package:rally/utils/responsive.dart';

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
  final AppThemeExtension? themeExt = Theme.of(context).extension<AppThemeExtension>();

  _showModernSnackBar(
    context,
    message,
    backgroundColor: themeExt?.successColor ?? Colors.green,
    textColor: Theme.of(context).colorScheme.onPrimary,
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
            SizedBox(width: Responsive.w(context, 12)),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
}
