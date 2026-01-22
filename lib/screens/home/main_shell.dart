import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/navigation/sliver_app_header.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/nav_item_data.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';

/// The main shell screen that hosts the bottom navigation bar.
///
/// Uses go_router's [StatefulNavigationShell] to preserve state across tab switches.
/// This is the primary container for the authenticated app experience.
class MainShell extends StatefulWidget {
  /// Creates a new [MainShell].
  const MainShell({super.key, required this.navigationShell});

  /// The navigation shell provided by go_router's StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

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
      NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: t.nav.home),
      NavItemData(icon: Icons.forum_outlined, activeIcon: Icons.forum, label: t.nav.chat),
      NavItemData(icon: Icons.search_outlined, activeIcon: Icons.search, label: t.nav.explore),
      NavItemData(
        icon: Icons.account_circle_outlined,
        activeIcon: Icons.account_circle,
        label: t.nav.profile,
      ),
    ];
  }

  void _onTabSelected(int index) {
    if (index == widget.navigationShell.currentIndex) return;

    // Reset scroll position when switching tabs
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Use go_router's goBranch to switch tabs
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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

  String _getScreenTitle(Translations t) {
    switch (widget.navigationShell.currentIndex) {
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

  String _getTitle(Translations t) {
    // For MainShell, just use the tab title
    return _getScreenTitle(t);
  }

  List<Widget>? _buildHeaderActions(int index) {
    // Show back button for nested routes
    // REMOVED as per user request

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

  /// Handle back navigation for top-level routes.
  /// - Non-home tabs (chat, explore, profile) → go to home
  /// - Home tab → show 'tap again to exit' snackbar
  /// Returns true if we handled the navigation, false to allow app exit.
  Future<bool> _handleBackNavigation() async {
    // Use GoRouter's location to determine current route - this is more reliable
    // than navigationShell.currentIndex after hot reload
    final GoRouter router = GoRouter.of(context);
    final String currentPath = router.routerDelegate.currentConfiguration.uri.path;
    final Translations t = Translations.of(context);

    // Determine if we're on home based on actual router location
    final bool isOnHome = currentPath == AppRoutes.home || currentPath == '/';

    // If not on home, navigate to home using context.go()
    // This is more reliable than goBranch() after hot reload
    if (!isOnHome) {
      context.go(AppRoutes.home);
      return true;
    }

    // On home tab - implement double-tap-to-exit
    final DateTime now = DateTime.now();
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {
      // Second tap within 2 seconds - allow exit
      return false;
    }

    // First tap - show snackbar and block exit
    _lastBackPressTime = now;
    showInfoSnackBar(context, t.common.tapAgainToExit);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = widget.navigationShell.currentIndex;
    final Translations t = Translations.of(context);
    final List<NavItemData> navItems = _buildNavItems(t);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Wrap with PopScope to handle back navigation.
    // - On non-home tabs: go to home
    // - On home tab: show 'tap again to exit' snackbar
    return PopScope(
      canPop: false, // Always block pop, we handle it ourselves
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final bool handled = await _handleBackNavigation();
          if (!handled) {
            // Use SystemNavigator.pop() for clean app exit
            // This bypasses any stale navigation state after hot reload
            await SystemNavigator.pop();
          }
        }
      },
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
              // 1. Main Content (Tabs)
              Positioned.fill(
                child: Builder(
                  builder: (BuildContext context) {
                    final double headerHeight = Responsive.h(context, 60);
                    final EdgeInsets currentPadding = MediaQuery.paddingOf(context);

                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        padding: currentPadding.copyWith(top: currentPadding.top + headerHeight),
                      ),
                      child: widget.navigationShell,
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
                        title: _getTitle(t),
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
