import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/notification_model.dart';

class NotificationNotifier extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    return <NotificationModel>[
      // Initial Mock Data
      NotificationModel(
        id: '1',
        title: 'Anna Bell',
        subtitle: 'Commented on your post: "Awesome trip! 🚗"',
        timeAgo: '2m ago',
        isUnread: true,
        avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
      ),
      NotificationModel(
        id: '2',
        title: 'System',
        subtitle: 'Welcome to Rally! Complete your profile to get started.',
        timeAgo: '1h ago',
        isUnread: true,
        icon: Icons.celebration_rounded,
        iconColor: Colors.blue,
      ),
      NotificationModel(
        id: '3',
        title: 'David Chen',
        subtitle: 'Invited you to join the "Weekend Drive" rally.',
        timeAgo: '1d ago',
        isUnread: false,
        avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
      ),
      NotificationModel(
        id: '4',
        title: 'Rally Team',
        subtitle: 'New features are available! Check out the map update.',
        timeAgo: '2d ago',
        isUnread: false,
        icon: Icons.map_rounded,
      ),
    ];
  }

  void markAsRead(String id) {
    state = <NotificationModel>[
      for (final NotificationModel notification in state)
        if (notification.id == id) notification.copyWith(isUnread: false) else notification,
    ];
  }

  void markAllAsRead() {
    state = <NotificationModel>[
      for (final NotificationModel notification in state) notification.copyWith(isUnread: false),
    ];
  }
}

final NotifierProvider<NotificationNotifier, List<NotificationModel>> notificationProvider =
    NotifierProvider<NotificationNotifier, List<NotificationModel>>(NotificationNotifier.new);

final Provider<int> unreadNotificationCountProvider = Provider<int>((Ref ref) {
  final List<NotificationModel> notifications = ref.watch(notificationProvider);
  return notifications.where((NotificationModel n) => n.isUnread).length;
});
