import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/themes/app_colors.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/pulsing_badge.dart';
import 'package:rally/widgets/common/scale_button.dart';
import 'package:rally/widgets/common/swipe_action_background.dart';

/// The chat screen displaying trip sessions and their associated chats.
///
/// Features swipe-to-action gestures, pinned chats, session thumbnails,
/// status badges, and animated unread indicators.
class ChatScreen extends StatefulWidget {
  /// Creates a new [ChatScreen].
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Track pinned chats
  final Set<String> _pinnedChats = <String>{};

  // Mock Data
  final List<Map<String, dynamic>> sessions = <Map<String, dynamic>>[
    <String, dynamic>{
      'title': 'Paris with the boys',
      'status': 'Active',
      'dates': 'Nov 12 - Nov 19',
      'image':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=200&auto=format&fit=crop',
      'memberCount': 5,
      'chats': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'paris_tp',
          'name': 'Trip Planning',
          'message': 'Did we book the Airbnb?',
          'time': '10:30 AM',
          'avatar': 'TP',
          'color': Colors.blueAccent,
          'unread': '2',
          'isOnline': true,
          'messageType': 'text',
        },
        <String, dynamic>{
          'id': 'paris_food',
          'name': 'Foodies',
          'message': 'Found a great croissant place!',
          'time': '9:15 AM',
          'avatar': 'F',
          'color': Colors.orangeAccent,
          'unread': '0',
          'isOnline': false,
          'messageType': 'location',
        },
        <String, dynamic>{
          'id': 'paris_alex',
          'name': 'Alex Johnson',
          'message': 'I\'ll bring the camera.',
          'time': 'Yesterday',
          'avatar': 'A',
          'color': Colors.purpleAccent,
          'unread': '0',
          'isOnline': true,
          'messageType': 'text',
        },
      ],
    },
    <String, dynamic>{
      'title': 'Korean BBQ Graduation',
      'status': 'Planning',
      'dates': 'Dec 05 - Dec 10',
      'image':
          'https://images.unsplash.com/photo-1590301157890-4810ed352733?q=80&w=200&auto=format&fit=crop',
      'memberCount': 8,
      'chats': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'bbq_log',
          'name': 'Logistics',
          'message': 'Reservation is at 7PM.',
          'time': 'Tue',
          'avatar': 'L',
          'color': Colors.redAccent,
          'unread': '5',
          'isOnline': false,
          'messageType': 'text',
        },
        <String, dynamic>{
          'id': 'bbq_sarah',
          'name': 'Sarah Lee',
          'message': 'Can I bring a +1?',
          'time': 'Mon',
          'avatar': 'S',
          'color': Colors.greenAccent,
          'unread': '1',
          'isOnline': true,
          'messageType': 'text',
        },
      ],
    },
    <String, dynamic>{
      'title': 'Hackathon 2026',
      'status': 'Cancelled',
      'dates': 'Jan 20 - Jan 22',
      'image': null,
      'memberCount': 4,
      'chats': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'hack_dev',
          'name': 'Dev Team',
          'message': 'Deployment is stuck.',
          'time': 'Mon',
          'avatar': 'D',
          'color': Colors.tealAccent,
          'unread': '12',
          'isOnline': false,
          'messageType': 'image',
        },
      ],
    },
  ];

  void _handleDismiss(DismissDirection direction, String chatId) {
    if (direction == DismissDirection.startToEnd) {
      // Pin action
      HapticFeedback.mediumImpact();
      setState(() {
        if (_pinnedChats.contains(chatId)) {
          _pinnedChats.remove(chatId);
        } else {
          _pinnedChats.add(chatId);
        }
      });
    } else {
      // Archive action
      HapticFeedback.mediumImpact();
      // Would normally archive here
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 20),
            Responsive.h(context, 10),
            Responsive.w(context, 20),
            Responsive.h(context, 100),
          ),
          itemCount: sessions.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> session = sessions[index];
            final List<Map<String, dynamic>> chats = session['chats'] as List<Map<String, dynamic>>;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Session Header
                      _buildSessionHeader(context, session, index),

                      // Chats Groups in a "Card"
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                          child: Column(
                            children: List<Widget>.generate(chats.length, (int chatIndex) {
                              final Map<String, dynamic> chat = chats[chatIndex];
                              final bool isLast = chatIndex == chats.length - 1;

                              return Column(
                                children: <Widget>[
                                  _buildSwipeableChatTile(context, chat, colorScheme),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      indent: Responsive.w(context, 76),
                                      endIndent: Responsive.w(context, 24),
                                      color: colorScheme.outline.withValues(alpha: 0.1),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionHeader(BuildContext context, Map<String, dynamic> session, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: Responsive.h(context, 12),
        top: index == 0 ? 0 : Responsive.h(context, 24),
      ),
      child: Row(
        children: <Widget>[
          // Session thumbnail
          Container(
            width: Responsive.w(context, 48),
            height: Responsive.w(context, 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
              color: colorScheme.primaryContainer,
              image:
                  session['image'] != null
                      ? DecorationImage(
                        image: NetworkImage(session['image'] as String),
                        fit: BoxFit.cover,
                      )
                      : null,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                session['image'] == null
                    ? Center(
                      child: Icon(
                        Icons.groups_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: Responsive.w(context, 24),
                      ),
                    )
                    : null,
          ),
          SizedBox(width: Responsive.w(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        session['title'] as String,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          fontSize: Responsive.w(context, 17),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 12)),
                    _buildStatusBadge(context, session['status'] as String),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today_rounded,
                      size: Responsive.w(context, 12),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: Responsive.w(context, 4)),
                    Text(
                      session['dates'] as String,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 12)),
                    Icon(
                      Icons.group_rounded,
                      size: Responsive.w(context, 12),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: Responsive.w(context, 4)),
                    Text(
                      '${session['memberCount']} members',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableChatTile(
    BuildContext context,
    Map<String, dynamic> chat,
    ColorScheme colorScheme,
  ) {
    final String chatId = chat['id'] as String;
    final bool isPinned = _pinnedChats.contains(chatId);

    return Dismissible(
      key: Key(chatId),
      confirmDismiss: (DismissDirection direction) async {
        _handleDismiss(direction, chatId);
        return false; // Don't actually dismiss, just trigger action
      },
      background: SwipeActionBackground(
        icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
        label: isPinned ? 'Unpin' : 'Pin',
        color: const Color(0xFF2196F3),
        isLeft: true,
      ),
      secondaryBackground: SwipeActionBackground.archive(isLeft: false),
      child: _buildChatTile(context, chat, isPinned),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat, bool isPinned) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasUnread = (int.tryParse(chat['unread'] as String? ?? '0') ?? 0) > 0;
    final bool isOnline = chat['isOnline'] as bool? ?? false;
    final String messageType = chat['messageType'] as String? ?? 'text';

    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to chat
      },
      child: Container(
        color: isPinned ? colorScheme.primaryContainer.withValues(alpha: 0.15) : Colors.transparent,
        padding: EdgeInsets.all(Responsive.w(context, 16)),
        child: Row(
          children: <Widget>[
            // Avatar with online indicator
            Stack(
              children: <Widget>[
                Container(
                  width: Responsive.w(context, 48),
                  height: Responsive.w(context, 48),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        (chat['color'] as Color).withValues(alpha: 0.3),
                        (chat['color'] as Color).withValues(alpha: 0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      chat['avatar'] as String,
                      style: TextStyle(
                        color: chat['color'] as Color,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.w(context, 16),
                      ),
                    ),
                  ),
                ),
                // Online indicator
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: Responsive.w(context, 14),
                      height: Responsive.w(context, 14),
                      decoration: BoxDecoration(
                        color: AppColors.success500,
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.surface, width: 2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.success500.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Pin indicator
                if (isPinned)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(Responsive.w(context, 2)),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: Responsive.w(context, 10),
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: Responsive.w(context, 16)),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          chat['name'] as String,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat['time'] as String,
                        style: textTheme.labelSmall?.copyWith(
                          color: hasUnread ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Row(
                    children: <Widget>[
                      // Message type indicator
                      if (messageType != 'text') ...<Widget>[
                        Icon(
                          _getMessageTypeIcon(messageType),
                          size: Responsive.w(context, 14),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: Responsive.w(context, 4)),
                      ],
                      Expanded(
                        child: Text(
                          chat['message'] as String,
                          style: textTheme.bodyMedium?.copyWith(
                            color: hasUnread ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...<Widget>[
                        SizedBox(width: Responsive.w(context, 8)),
                        PulsingBadge(count: chat['unread'] as String, animate: true),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMessageTypeIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image_rounded;
      case 'location':
        return Icons.location_on_rounded;
      case 'file':
        return Icons.attach_file_rounded;
      case 'voice':
        return Icons.mic_rounded;
      default:
        return Icons.chat_bubble_rounded;
    }
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final (Color color, IconData icon) = _getStatusData(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 10),
        vertical: Responsive.h(context, 4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: Responsive.w(context, 12), color: color),
          SizedBox(width: Responsive.w(context, 4)),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: Responsive.w(context, 10),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getStatusData(String status) {
    switch (status) {
      case 'Active':
        return (const Color(0xFF4CAF50), Icons.flight_takeoff_rounded);
      case 'Planning':
        return (const Color(0xFFFF9800), Icons.edit_note_rounded);
      case 'Cancelled':
        return (const Color(0xFF9E9E9E), Icons.cancel_rounded);
      case 'Completed':
        return (const Color(0xFF2196F3), Icons.check_circle_rounded);
      default:
        return (const Color(0xFF607D8B), Icons.circle);
    }
  }
}
