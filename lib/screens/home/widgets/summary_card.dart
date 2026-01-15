import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/glass_container.dart';

/// A card widget displaying summary statistics on the home screen.
class SummaryCard extends StatelessWidget {
  /// The title of the card (e.g., "Active Rallies").
  final String title;

  /// The value to display (e.g., number of rallies).
  final String value;

  /// The icon to allow visual identification.
  final IconData icon;

  /// The primary color of the icon and background accents.
  final Color? color;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Creates a [SummaryCard].
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color itemColor = color ?? colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        opacity: 0.05,
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
        borderColor: colorScheme.outline.withValues(alpha: 0.1),
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(Responsive.w(context, 8)),
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: itemColor, size: Responsive.w(context, 20)),
              ),
              SizedBox(height: Responsive.h(context, 12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
