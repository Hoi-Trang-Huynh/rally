import 'package:flutter/material.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/nav_item_data.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';
import '../profile/profile_screen.dart';

/// Placeholder screen widget for tabs not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.construction_outlined, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(title, style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(
            t.nav.comingSoon,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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

  @override
  Widget build(BuildContext context) {
    final Translations t = Translations.of(context);
    final List<NavItemData> navItems = _buildNavItems(t);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          _PlaceholderScreen(title: t.nav.home),
          _PlaceholderScreen(title: t.nav.chat),
          _PlaceholderScreen(title: t.nav.explore),
          const ProfileScreen(),
        ],
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
