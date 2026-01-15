import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A container for a group of settings tiles with an optional title.
class SettingsGroup extends StatelessWidget {
  /// The title for this group of settings.
  final String? title;

  /// The list of settings tiles (usually [ModernSettingsTile]).
  final List<Widget> children;

  /// Creates a [SettingsGroup].
  const SettingsGroup({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: EdgeInsets.only(
              left: Responsive.w(context, 20),
              bottom: Responsive.h(context, 8),
              top: Responsive.h(context, 4),
            ),
            child: Text(
              title!,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            children:
                children.map((Widget child) {
                  // Add dividers between items, but not after the last one
                  final int index = children.indexOf(child);
                  final bool isLast = index == children.length - 1;

                  return Column(
                    children: <Widget>[
                      child,
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(left: 72, right: 16),
                          child: Divider(
                            height: 1,
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
