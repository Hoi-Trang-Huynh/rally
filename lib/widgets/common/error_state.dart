import 'package:flutter/material.dart';

import 'empty_state.dart';

/// A reusable widget to display an error state.
///
/// Wraps [EmptyState] with error-specific styling.
class ErrorState extends StatelessWidget {
  /// Creates an [ErrorState].
  const ErrorState({required this.error, super.key, this.onRetry, this.retryLabel});

  /// The error message to display.
  final String error;

  /// Callback for the retry button.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to 'Retry'.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    // We can just reuse EmptyState but customized for errors
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Oops!',
      subtitle: error,
      actionLabel: retryLabel ?? 'Retry',
      onAction: onRetry,
    );
  }
}
