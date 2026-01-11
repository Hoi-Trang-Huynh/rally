import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;

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
            padding: const EdgeInsets.only(left: 20, bottom: 8, top: 4),
            child: Text(
              title!,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
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
                            color: colorScheme.outlineVariant.withOpacity(0.5),
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
