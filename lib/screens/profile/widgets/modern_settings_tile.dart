import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A polished, modern ListTile replacement for settings screens.
class ModernSettingsTile extends StatelessWidget {
  /// The icon to display on the left.
  final IconData icon;

  /// The main title of the tile.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Custom widget to display on the trailing edge (e.g., Switch).
  final Widget? trailing;

  /// Custom color for the icon.
  final Color? iconColor;

  /// Custom background color for the icon container.
  final Color? iconBackgroundColor;

  /// Whether this action is destructive (e.g., Logout, Delete account).
  final bool isDestructive;

  /// Creates a [ModernSettingsTile].
  const ModernSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.iconBackgroundColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 16),
            vertical: Responsive.h(context, 12),
          ),
          child: Row(
            children: <Widget>[
              // Icon container
              Container(
                width: Responsive.w(context, 40),
                height: Responsive.w(context, 40),
                decoration: BoxDecoration(
                  color:
                      iconBackgroundColor ??
                      (isDestructive
                          ? colorScheme.errorContainer.withValues(alpha: 0.4)
                          : colorScheme.surfaceContainerHigh),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? (isDestructive ? colorScheme.error : colorScheme.primary),
                  size: Responsive.w(context, 22),
                ),
              ),
              SizedBox(width: Responsive.w(context, 16)),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? colorScheme.error : colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      SizedBox(height: Responsive.h(context, 2)),
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget (usually chevron or switch)
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: Responsive.w(context, 20),
                  color: colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
