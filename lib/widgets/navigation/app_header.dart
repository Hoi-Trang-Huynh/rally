import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/notification_provider.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/notifications/notification_sheet.dart';

/// A reusable application header that implements [PreferredSizeWidget].
///
/// Displays the [title] on the left and a notification icon on the right,
/// along with any optional [actions].
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  /// Creates a new [AppHeader].
  const AppHeader({super.key, required this.title, required this.parentTitle, this.actions});

  /// The title text to display in the header.
  final String title;

  final String parentTitle;

  /// Optional list of widgets to display after the notification icon.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int unreadCount = ref.watch(unreadNotificationCountProvider);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: Responsive.h(context, 80),
      title: Padding(
        padding: EdgeInsets.only(left: Responsive.w(context, 8), top: Responsive.h(context, 8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Page Title: 28px (semibold)
            Text(
              title,
              style: textTheme.headlineMedium?.copyWith(
                fontSize: Responsive.w(context, 28),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            SizedBox(height: Responsive.h(context, 2)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Text(
                    parentTitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: Responsive.w(context, 12),
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 4)),
                    child: Text(
                      '/',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: Responsive.w(context, 12),
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Notification Icon: 30x30px
        Center(
          child: IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => const NotificationSheet(),
              );
            },
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              backgroundColor: colorScheme.error,
              child: Icon(
                Icons.notifications_outlined,
                color: colorScheme.onSurfaceVariant,
                size: Responsive.w(context, 30),
              ),
            ),
          ),
        ),
        if (actions != null) ...actions!,
        SizedBox(width: Responsive.w(context, 16)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
