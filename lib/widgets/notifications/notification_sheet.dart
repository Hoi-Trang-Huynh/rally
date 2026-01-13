import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/notification_model.dart';
import 'package:rally/providers/notification_provider.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/notifications/notification_item.dart';

class NotificationSheet extends ConsumerWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<NotificationModel> notifications = ref.watch(notificationProvider);

    final List<NotificationModel> newNotifications =
        notifications.where((NotificationModel n) => n.isUnread).toList();
    final List<NotificationModel> earlierNotifications =
        notifications.where((NotificationModel n) => !n.isUnread).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: <Widget>[
              // Handle
              SizedBox(height: Responsive.h(context, 12)),
              Container(
                width: Responsive.w(context, 40),
                height: Responsive.h(context, 4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 24),
                  Responsive.h(context, 16),
                  Responsive.w(context, 24),
                  Responsive.h(context, 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Notifications',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(notificationProvider.notifier).markAllAsRead();
                      },
                      child: const Text('Mark all as read'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(bottom: Responsive.h(context, 24)),
                  children: <Widget>[
                    if (newNotifications.isNotEmpty) ...<Widget>[
                      _buildSectionHeader(context, 'New'),
                      ...newNotifications.map(
                        (NotificationModel n) => NotificationItem(
                          title: n.title,
                          subtitle: n.subtitle,
                          timeAgo: n.timeAgo,
                          isUnread: n.isUnread,
                          avatarUrl: n.avatarUrl,
                          icon: n.icon,
                          iconColor: n.iconColor,
                        ),
                      ),
                    ],
                    if (earlierNotifications.isNotEmpty) ...<Widget>[
                      _buildSectionHeader(context, 'Earlier'),
                      ...earlierNotifications.map(
                        (NotificationModel n) => NotificationItem(
                          title: n.title,
                          subtitle: n.subtitle,
                          timeAgo: n.timeAgo,
                          isUnread: n.isUnread,
                          avatarUrl: n.avatarUrl,
                          icon: n.icon,
                          iconColor: n.iconColor,
                        ),
                      ),
                    ],
                    if (notifications.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(Responsive.w(context, 32)),
                        child: Center(
                          child: Text(
                            'No notifications',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        Responsive.h(context, 24),
        Responsive.w(context, 24),
        Responsive.h(context, 8),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
