import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rally/widgets/visuals/scale_button.dart';

/// A reusable widget to display an empty state.
///
/// Features a large centered icon, title, description, and an optional action button.
class EmptyState extends StatelessWidget {
  /// Creates an [EmptyState].
  const EmptyState({
    required this.title,
    super.key,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// The main text to display.
  final String title;

  /// The secondary text to display.
  final String? subtitle;

  /// The icon to display above the text.
  ///
  /// Defaults to [Icons.inbox_outlined] if null.
  final IconData? icon;

  /// The label for the action button.
  ///
  /// If null, the button will not be shown.
  final String? actionLabel;

  /// The callback for the action button.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Icon Bubble
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 8),
              // Subtitle
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],

            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 32),
              // Action Button
              ScaleButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onAction!();
                },
                child: FilledButton.tonal(
                  onPressed: null, // Handled by ScaleButton
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
