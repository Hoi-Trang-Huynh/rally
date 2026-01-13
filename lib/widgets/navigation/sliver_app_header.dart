import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/notification_provider.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/notifications/notification_sheet.dart';

/// A scroll-aware application header that hides on scroll down and shows on scroll up.
///
/// This widget uses [SliverAppBar] with `floating` and `snap` properties to achieve
/// smooth show/hide animations based on scroll direction.
///
/// Features:
/// - Styled notification button with animated badge
/// - User avatar for personalization
/// - Smooth scroll-based show/hide animations
class SliverAppHeader extends ConsumerWidget {
  /// Creates a new [SliverAppHeader].
  const SliverAppHeader({super.key, required this.title, required this.parentTitle, this.actions});

  /// The title text to display in the header.
  final String title;

  /// The parent/breadcrumb title (e.g., "Rally").
  final String parentTitle;

  /// Optional list of widgets to display after the notification icon.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int unreadCount = ref.watch(unreadNotificationCountProvider);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);

    // Calculate header height: safe area + content height
    final double contentHeight = Responsive.h(context, 56);
    final double headerHeight = safePadding.top + contentHeight;

    return SliverAppBar(
      expandedHeight: headerHeight,
      collapsedHeight: 0,
      toolbarHeight: 0,
      floating: true,
      snap: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(color: colorScheme.surface),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Left side: Title and breadcrumb
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Breadcrumb
                        Row(
                          children: <Widget>[
                            Text(
                              parentTitle,
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: Responsive.w(context, 12),
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 6)),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: Responsive.w(context, 14),
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.h(context, 2)),
                        // Page Title
                        Text(
                          title,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: Responsive.w(context, 26),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side: Actions row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Notification Button
                      _NotificationButton(
                        unreadCount: unreadCount,
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) => const NotificationSheet(),
                          );
                        },
                      ),
                      if (actions != null) ...<Widget>[
                        SizedBox(width: Responsive.w(context, 8)),
                        ...actions!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Styled notification button with animated badge.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.unreadCount, required this.onPressed});

  final int unreadCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasUnread = unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        child: Container(
          padding: EdgeInsets.all(Responsive.w(context, 10)),
          decoration: BoxDecoration(
            color:
                hasUnread
                    ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            border: Border.all(
              color:
                  hasUnread
                      ? colorScheme.primary.withValues(alpha: 0.2)
                      : colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Icon(
                hasUnread ? Icons.notifications_rounded : Icons.notifications_outlined,
                color: hasUnread ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: Responsive.w(context, 22),
              ),
              // Custom Badge
              if (hasUnread)
                Positioned(
                  right: -Responsive.w(context, 10),
                  top: -Responsive.w(context, 10),
                  child: _AnimatedBadge(count: unreadCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated badge with gradient and subtle animation.
class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({required this.count});

  final int count;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        constraints: BoxConstraints(
          minWidth: Responsive.w(context, 16),
          minHeight: Responsive.w(context, 16),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 4),
          vertical: Responsive.w(context, 1),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[colorScheme.error, colorScheme.error.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.error.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.count > 99 ? '99+' : '${widget.count}',
          style: TextStyle(
            color: colorScheme.onError,
            fontSize: Responsive.w(context, 10),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
