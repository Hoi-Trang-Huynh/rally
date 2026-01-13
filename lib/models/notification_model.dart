import 'package:flutter/material.dart';

class NotificationModel {
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

  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isUnread;
  final String? avatarUrl;
  final IconData? icon;
  final Color? iconColor;

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
