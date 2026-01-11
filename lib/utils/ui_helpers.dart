import 'package:flutter/material.dart';

/// Shared UI helper functions.

/// Shows an error snackbar with the given message.
void showErrorSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
  );
}

/// Shows a success snackbar with the given message.
void showSuccessSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
}

/// Shows an info snackbar with the given message.
void showInfoSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.blueGrey));
}
