import 'package:flutter/material.dart';

/// A model representing a notification item.
class NotificationModel {
  /// Creates a [NotificationModel].
  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isUnread = false,
    this.avatarUrl,
    this.icon,
    this.iconColor,
  });

  /// The unique identifier for the notification.
  final String id;

  /// The title of the notification (e.g., sender name).
  final String title;

  /// The subtitle or body text of the notification.
  final String subtitle;

  /// A string representing how long ago the notification was received.
  final String timeAgo;

  /// Whether the notification is unread.
  final bool isUnread;

  /// URL of the avatar image to display (optional).
  final String? avatarUrl;

  /// Icon to display if no avatar is provided (optional).
  final IconData? icon;

  /// Color of the icon (optional).
  final Color? iconColor;

  /// Creates a copy of this [NotificationModel] with the given fields replaced with new values.
  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? timeAgo,
    bool? isUnread,
    String? avatarUrl,
    IconData? icon,
    Color? iconColor,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}
