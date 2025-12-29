import 'package:flutter/material.dart';

import '../../models/nav_item_data.dart';
import '../../widgets/navigation/app_bottom_nav_bar.dart';

/// Placeholder screen widget for tabs not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.construction_outlined, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(title, style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
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

  /// Navigation items configuration.
  static const List<NavItemData> _navItems = <NavItemData>[
    NavItemData(icon: Icons.cottage_outlined, activeIcon: Icons.cottage, label: 'Home'),
    NavItemData(icon: Icons.forum_outlined, activeIcon: Icons.forum, label: 'Chat'),
    NavItemData(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Explore'),
    NavItemData(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle,
      label: 'Profile',
    ),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onActionPressed() {
    // TODO: Implement action button functionality (e.g., create new rally)
    debugPrint('Action button pressed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Rally - Coming soon!'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const <Widget>[
          _PlaceholderScreen(title: 'Home'),
          _PlaceholderScreen(title: 'Chat'),
          _PlaceholderScreen(title: 'Explore'),
          _PlaceholderScreen(title: 'Profile'),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: _onTabSelected,
        onActionPressed: _onActionPressed,
        items: _navItems,
      ),
    );
  }
}
