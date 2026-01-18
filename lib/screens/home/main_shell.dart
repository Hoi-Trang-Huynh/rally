import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/router/route_metadata.dart';
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
      NavItemData(icon: Icons.map_outlined, activeIcon: Icons.map, label: t.nav.explore),
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

  /// Get current location from GoRouter.
  String _getCurrentLocation() {
    return GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
  }

  /// Get current URI from GoRouter.
  Uri _getCurrentUri() {
    return GoRouter.of(context).routerDelegate.currentConfiguration.uri;
  }

  List<String> _getBreadcrumbs() {
    final String location = _getCurrentLocation();
    return RouteMetadataRegistry.getBreadcrumbs(context, location);
  }

  String _getTitle(Translations t) {
    final String location = _getCurrentLocation();
    final Uri uri = _getCurrentUri();

    // Try to get title from route metadata
    final String? metadataTitle = RouteMetadataRegistry.getTitle(context, location, uri);
    if (metadataTitle != null) {
      return metadataTitle;
    }

    // Default: tab title
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

  /// Check if current route is a nested route that should pop to parent.
  bool _isNestedRoute() {
    return RouteMetadataRegistry.isNestedRoute(_getCurrentLocation());
  }

  /// Get the parent route for the current nested route.
  String? _getParentRoute() {
    return RouteMetadataRegistry.getParentRoute(_getCurrentLocation());
  }

  /// Handle back navigation for nested routes.
  /// Returns true if we handled the navigation, false to allow default behavior.
  Future<bool> _handleBackNavigation() async {
    if (_isNestedRoute()) {
      final String? parentRoute = _getParentRoute();
      if (parentRoute != null) {
        context.go(parentRoute);
        return true; // We handled it
      }
    }
    return false; // Let default behavior happen
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = widget.navigationShell.currentIndex;
    final Translations t = Translations.of(context);
    final List<NavItemData> navItems = _buildNavItems(t);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Wrap with PopScope to handle back navigation for nested routes.
    // When on a nested route (like /explore/user/...), pressing back should
    // go to the parent route (/explore) instead of exiting the app.
    return PopScope(
      canPop: !_isNestedRoute(), // Block pop if we're on a nested route
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          // We blocked the pop, so handle it ourselves
          await _handleBackNavigation();
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
