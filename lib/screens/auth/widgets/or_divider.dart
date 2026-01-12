import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';

/// A reusable horizontal divider with "Or" text in the middle.
///
/// Used to separate primary actions from alternative options (e.g., social login).
class OrDivider extends StatelessWidget {
  /// Creates a new [OrDivider].
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: colorScheme.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            t.common.orDivider,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outline)),
      ],
    );
  }
}
