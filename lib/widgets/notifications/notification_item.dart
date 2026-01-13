import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.isUnread,
    this.avatarUrl,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isUnread;
  final String? avatarUrl;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        // TODO: Handle notification tap
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 24),
          vertical: Responsive.h(context, 12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Avatar / Icon
            Container(
              width: Responsive.w(context, 48),
              height: Responsive.w(context, 48),
              decoration: BoxDecoration(
                color:
                    isUnread
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                image:
                    avatarUrl != null
                        ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover)
                        : null,
              ),
              child:
                  avatarUrl == null
                      ? Icon(
                        icon ?? Icons.notifications_rounded,
                        color:
                            isUnread
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                        size: Responsive.w(context, 24),
                      )
                      : null,
            ),
            SizedBox(width: Responsive.w(context, 16)),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: Responsive.w(context, 15),
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '  '),
                        TextSpan(
                          text: timeAgo,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: Responsive.w(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color:
                          isUnread
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread Indicator
            if (isUnread)
              Container(
                margin: EdgeInsets.only(
                  left: Responsive.w(context, 8),
                  top: Responsive.h(context, 8),
                ),
                width: Responsive.w(context, 8),
                height: Responsive.w(context, 8),
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
