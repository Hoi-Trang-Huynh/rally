import 'package:flutter/material.dart';
import 'package:rally/screens/profile/settings_screen.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/navigation/sliver_app_header.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/nav_item_data.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Placeholder screen widget for tabs not yet implemented.
class _PlaceholderScreen extends StatefulWidget {
  const _PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  State<_PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<_PlaceholderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)
      ..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Animated icon with subtle pulse
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (BuildContext context, Widget? child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(context, 24)),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: Responsive.w(context, 48),
                    color: colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: Responsive.h(context, 24)),
          Text(
            widget.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 16),
              vertical: Responsive.h(context, 8),
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
            ),
            child: Text(
              t.nav.comingSoon,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// The main shell screen that hosts the bottom navigation bar.
///
/// Uses [IndexedStack] to preserve state across tab switches.
/// This is the primary container for the authenticated app experience.
class MainShell extends StatefulWidget {
  /// Creates a new [MainShell].
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

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
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void _onActionPressed() {
    final Translations t = Translations.of(context);
    debugPrint('Action button pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${t.nav.createRally} - ${t.nav.comingSoon}!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getScreenTitle(int index, Translations t) {
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

  List<Widget>? _buildHeaderActions(int index) {
    // Add specific actions per tab if needed
    if (index == 3) {
      // Profile Tab
      return <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (BuildContext context) => const SettingsScreen()),
            );
          },
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

  Widget _buildScreen(int index, Translations t) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey<int>(0));
      case 1:
        return _PlaceholderScreen(
          key: const ValueKey<int>(1),
          title: t.nav.chat,
          icon: Icons.forum,
        );
      case 2:
        return _PlaceholderScreen(
          key: const ValueKey<int>(2),
          title: t.nav.explore,
          icon: Icons.explore,
        );
      case 3:
        return const ProfileScreen(key: ValueKey<int>(3));
      default:
        return _PlaceholderScreen(
          key: const ValueKey<int>(0),
          title: t.nav.home,
          icon: Icons.cottage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Translations t = Translations.of(context);
    final List<NavItemData> navItems = _buildNavItems(t);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true, // Content flows behind floating nav bar
      extendBodyBehindAppBar: true,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppHeader(
              title: _getScreenTitle(_currentIndex, t),
              parentTitle: 'Rally',
              actions: _buildHeaderActions(_currentIndex),
            ),
          ];
        },
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutQuart,
          switchOutCurve: Curves.easeInQuart,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final bool isEntering = child.key == ValueKey<int>(_currentIndex);

            // Subtle scale and fade transition
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: const Interval(0.2, 1.0), // Delay fade in slightly
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: isEntering ? 0.95 : 1.05, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildScreen(_currentIndex, t),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: _onTabSelected,
        onActionPressed: _onActionPressed,
        items: navItems,
      ),
    );
  }
}
