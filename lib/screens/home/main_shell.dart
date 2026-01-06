import 'package:flutter/material.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/nav_item_data.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';
import '../profile/profile_screen.dart';

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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 48, color: colorScheme.primary),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            widget.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
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
  int _previousIndex = 0;

  /// Build navigation items with translations.
  List<NavItemData> _buildNavItems(Translations t) {
    return <NavItemData>[
      NavItemData(icon: Icons.cottage_outlined, activeIcon: Icons.cottage, label: t.nav.home),
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
      _previousIndex = _currentIndex;
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

  Widget _buildScreen(int index, Translations t) {
    switch (index) {
      case 0:
        return _PlaceholderScreen(
          key: const ValueKey<int>(0),
          title: t.nav.home,
          icon: Icons.cottage,
        );
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

    // Determine slide direction based on navigation
    final bool slidingRight = _currentIndex > _previousIndex;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Fade + subtle slide transition
          final bool isEntering = child.key == ValueKey<int>(_currentIndex);
          final double slideOffset =
              isEntering ? (slidingRight ? 0.05 : -0.05) : (slidingRight ? -0.05 : 0.05);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(slideOffset, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildScreen(_currentIndex, t),
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
