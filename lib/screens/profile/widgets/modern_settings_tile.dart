import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

class ModernSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool isDestructive;

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
