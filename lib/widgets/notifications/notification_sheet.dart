import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/notification_model.dart';
import 'package:rally/providers/notification_provider.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/notifications/notification_item.dart';

/// A bottom sheet displaying the user's notifications.
class NotificationSheet extends ConsumerWidget {
  /// Creates a [NotificationSheet].
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);
    final List<NotificationModel> notifications = ref.watch(notificationProvider);

    final List<NotificationModel> newNotifications =
        notifications.where((NotificationModel n) => n.isUnread).toList();
    final List<NotificationModel> earlierNotifications =
        notifications.where((NotificationModel n) => !n.isUnread).toList();

    return AppBottomSheet.draggable(
      title: t.notifications.title,
      action: TextButton(
        onPressed: () {
          ref.read(notificationProvider.notifier).markAllAsRead();
        },
        child: Text(
          t.notifications.markAllAsRead,
          style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
        ),
      ),
      bodyBuilder: (ScrollController scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.only(bottom: Responsive.h(context, 24)),
          children: <Widget>[
            if (newNotifications.isNotEmpty) ...<Widget>[
              _buildSectionHeader(context, t.notifications.newSection),
              ...newNotifications.map(
                (NotificationModel n) => NotificationItem(
                  title: n.title,
                  subtitle: n.subtitle,
                  timeAgo: n.timeAgo,
                  isUnread: n.isUnread,
                  avatarUrl: n.avatarUrl,
                  icon: n.icon,
                  iconColor: n.iconColor,
                  onTap: () => ref.read(notificationProvider.notifier).markAsRead(n.id),
                ),
              ),
            ],
            if (earlierNotifications.isNotEmpty) ...<Widget>[
              _buildSectionHeader(context, t.notifications.earlier),
              ...earlierNotifications.map(
                (NotificationModel n) => NotificationItem(
                  title: n.title,
                  subtitle: n.subtitle,
                  timeAgo: n.timeAgo,
                  isUnread: n.isUnread,
                  avatarUrl: n.avatarUrl,
                  icon: n.icon,
                  iconColor: n.iconColor,
                  onTap: () => ref.read(notificationProvider.notifier).markAsRead(n.id),
                ),
              ),
            ],
            if (notifications.isEmpty)
              Padding(
                padding: EdgeInsets.all(Responsive.w(context, 32)),
                child: Center(
                  child: Text(
                    t.notifications.noNotifications,
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
          ],
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
