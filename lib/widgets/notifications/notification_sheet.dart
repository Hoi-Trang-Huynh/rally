import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/notification_model.dart';
import 'package:rally/models/responses/pending_invitation_response.dart';
import 'package:rally/providers/notification_provider.dart';
import 'package:rally/providers/user_provider.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/notifications/invitation_card.dart';
import 'package:rally/widgets/notifications/notification_item.dart';

/// A bottom sheet displaying notifications and pending invitations in separate tabs.
class NotificationSheet extends ConsumerStatefulWidget {
  /// Creates a [NotificationSheet].
  const NotificationSheet({super.key});

  @override
  ConsumerState<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends ConsumerState<NotificationSheet> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return AppBottomSheet.draggable(
      title: t.notifications.title,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      bodyBuilder: (ScrollController scrollController) {
        return <Widget>[
          // Tab header
          SliverToBoxAdapter(
            child: _buildTabHeader(context, colorScheme, textTheme, t),
          ),
          // Tab content
          if (_selectedTab == 0)
            ..._buildNotificationsSlivers(context, t, colorScheme, textTheme)
          else
            ..._buildInvitationsSlivers(context, t, colorScheme, textTheme),
        ];
      },
    );
  }

  Widget _buildTabHeader(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 24),
      ),
      child: Row(
        children: <Widget>[
          _buildTab(
            context,
            label: t.notifications.title,
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          SizedBox(width: Responsive.w(context, 16)),
          _buildTab(
            context,
            label: t.notifications.invitations.sectionTitle,
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 16),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNotificationsSlivers(
    BuildContext context,
    Translations t,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final List<NotificationModel> notifications = ref.watch(notificationProvider);
    final List<NotificationModel> newNotifications =
        notifications.where((NotificationModel n) => n.isUnread).toList();
    final List<NotificationModel> earlierNotifications =
        notifications.where((NotificationModel n) => !n.isUnread).toList();

    if (notifications.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.w(context, 32)),
              child: Text(
                t.notifications.noNotifications,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ];
    }

    return <Widget>[
      // Mark all as read
      SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: Responsive.w(context, 24),
              top: Responsive.h(context, 8),
            ),
            child: TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 8),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t.notifications.markAllAsRead,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
      if (newNotifications.isNotEmpty) ...<Widget>[
        SliverToBoxAdapter(child: _buildSectionHeader(context, t.notifications.newSection)),
        SliverList(
          delegate: SliverChildListDelegate(
            newNotifications
                .map(
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
                )
                .toList(),
          ),
        ),
      ],
      if (earlierNotifications.isNotEmpty) ...<Widget>[
        SliverToBoxAdapter(child: _buildSectionHeader(context, t.notifications.earlier)),
        SliverList(
          delegate: SliverChildListDelegate(
            earlierNotifications
                .map(
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
                )
                .toList(),
          ),
        ),
      ],
      // Bottom padding
      SliverToBoxAdapter(
        child: SizedBox(height: Responsive.h(context, 24)),
      ),
    ];
  }

  List<Widget> _buildInvitationsSlivers(
    BuildContext context,
    Translations t,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final AsyncValue<PendingInvitationsResponse> invitationsAsync =
        ref.watch(pendingInvitationsProvider);

    return invitationsAsync.when(
      data: (PendingInvitationsResponse data) {
        if (data.invitations.isEmpty) {
          return <Widget>[
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(context, 32)),
                  child: Text(
                    t.notifications.invitations.noInvitations,
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ];
        }
        return <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              data.invitations
                  .map(
                    (PendingInvitationItem inv) => InvitationCard(
                      invitation: inv,
                      onView: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.invitationDetail(inv.rallyId, inv.participantId));
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: Responsive.h(context, 24)),
          ),
        ];
      },
      loading: () => <Widget>[
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ],
      error: (Object error, StackTrace stack) {
        debugPrint('Pending invitations error: $error');
        return <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(context, 32)),
                child: Text(
                  t.notifications.invitations.noInvitations,
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ];
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
