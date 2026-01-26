import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/navigation/sliver_app_header.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/nav_item_data.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';

/// The main shell screen that hosts the bottom navigation bar.
///
/// Uses go_router's [StatefulNavigationShell] to preserve state across tab switches.
/// This is the primary container for the authenticated app experience.
class MainShell extends StatefulWidget {
  /// Creates a new [MainShell].
  const MainShell({super.key, required this.child});

  /// The child widget provided by go_router's ShellRoute.
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Scroll controller for the NestedScrollView
  final ScrollController _scrollController = ScrollController();
  bool _isNavbarVisible = true;

  /// Timestamp of last back press for double-tap-to-exit functionality.
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    // Listen to router changes to update header (e.g. title, breadcrumbs)
    GoRouter.of(context).routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    GoRouter.of(context).routerDelegate.removeListener(_onRouteChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Build navigation items with translations.
  List<NavItemData> _buildNavItems(Translations t) {
    return <NavItemData>[
      NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: t.nav.home,
        iconSize: 30,
      ),
      NavItemData(
        icon: Icons.forum_outlined,
        activeIcon: Icons.forum,
        label: t.nav.chat,
        iconSize: 26,
      ),
      NavItemData(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: t.nav.explore,
        iconSize: 30,
      ),
      NavItemData(
        icon: Icons.person_outlined,
        activeIcon: Icons.person,
        label: t.nav.profile,
        iconSize: 32,
      ),
    ];
  }

  int _getCurrentIndex(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    final String location = router.routerDelegate.currentConfiguration.uri.path;

    if (location.startsWith(AppRoutes.chat)) return 1;
    if (location.startsWith(AppRoutes.explore)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0; // Default to home (index 0)
  }

  void _onTabSelected(int index) {
    final int currentIndex = _getCurrentIndex(context);
    if (index == currentIndex) {
      // If tapping same tab, could scroll to top or reset stack
      // For shell route, usually we just ensure we are at the root of that tab
      return;
    }

    // Reset scroll position when switching tabs
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.chat);
        break;
      case 2:
        context.go(AppRoutes.explore);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }

  void _onActionPressed() {
    final Translations t = Translations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${t.nav.createRally} - ${t.nav.comingSoon}!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getScreenTitle(Translations t, int index) {
    switch (index) {
      case 0:
        return t.nav.home;
      case 1:
        return t.nav.chat;
      case 2:
        return t.nav.explore;
      case 3:
        return t.nav.profile;
      default:
        return t.nav.home;
    }
  }

  List<String> _getBreadcrumbs() {
    // For MainShell, we only show Rally + current tab as breadcrumbs
    // (User profiles and other nested routes are now outside the shell)
    return <String>['Rally'];
  }

  String _getTitle(Translations t, int index) {
    // For MainShell, just use the tab title
    return _getScreenTitle(t, index);
  }

  List<Widget>? _buildHeaderActions(int index) {
    // Profile tab: show settings button
    if (index == 3) {
      return <Widget>[
        IconButton(
          onPressed: () => context.push(AppRoutes.settings),
          icon: Icon(
            Icons.settings_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: Responsive.w(context, 24),
          ),
        ),
      ];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);
    final Translations t = Translations.of(context);
    final List<NavItemData> navItems = _buildNavItems(t);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool onHome = currentIndex == 0;

    return PopScope(
      canPop: onHome, // Always block pop, we handle it ourselves
      onPopInvokedWithResult: (bool didPop, dynamic result) async {},
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        extendBody: true, // Content flows behind navbar for floating effect
        extendBodyBehindAppBar: true,
        body: NotificationListener<UserScrollNotification>(
          onNotification: (UserScrollNotification notification) {
            if (notification.direction == ScrollDirection.reverse && _isNavbarVisible) {
              setState(() => _isNavbarVisible = false);
            } else if (notification.direction == ScrollDirection.forward && !_isNavbarVisible) {
              setState(() => _isNavbarVisible = true);
            }
            return false;
          },
          child: Stack(
            children: <Widget>[
              // 1. Main Content (The child widget - Chat/Home/etc)
              Positioned.fill(
                child: Builder(
                  builder: (BuildContext context) {
                    final double headerHeight = Responsive.h(context, 60);
                    final EdgeInsets currentPadding = MediaQuery.paddingOf(context);

                    // Inject padding for the fixed header
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        padding: currentPadding.copyWith(top: currentPadding.top + headerHeight),
                      ),
                      child: widget.child,
                    );
                  },
                ),
              ),

              // 2. Overlaid Header (Slide Up to hide)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: Responsive.h(context, 60) + MediaQuery.paddingOf(context).top,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  offset: _isNavbarVisible ? Offset.zero : const Offset(0, -1),
                  child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppHeader(
                        title: _getTitle(t, currentIndex),
                        breadcrumbs: _getBreadcrumbs(),
                        actions: _buildHeaderActions(currentIndex),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AnimatedSlide(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          offset: _isNavbarVisible ? Offset.zero : const Offset(0, 1),
          child: AppBottomNavBar(
            currentIndex: currentIndex,
            onIndexChanged: _onTabSelected,
            onActionPressed: _onActionPressed,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
