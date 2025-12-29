import 'package:flutter/material.dart';

import '../../models/nav_item_data.dart';
import 'nav_bar_action_button.dart';
import 'nav_bar_item.dart';

/// The main bottom navigation bar widget for the Rally app.
///
/// Displays navigation items with a floating action button in the center.
/// Uses M3 theme colors and supports both light and dark themes.
class AppBottomNavBar extends StatelessWidget {
  /// Creates a new [AppBottomNavBar].
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onActionPressed,
    required this.items,
  });

  /// The currently selected tab index.
  final int currentIndex;

  /// Callback when a navigation item is selected.
  final ValueChanged<int> onIndexChanged;

  /// Callback when the central action button is pressed.
  final VoidCallback onActionPressed;

  /// The list of navigation items to display.
  /// Should have exactly 4 items (2 on each side of the action button).
  final List<NavItemData> items;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    assert(items.length == 4, 'AppBottomNavBar requires exactly 4 items');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Left side items (Home, Chat)
              NavBarItem(
                item: items[0],
                isSelected: currentIndex == 0,
                onTap: () => onIndexChanged(0),
              ),
              NavBarItem(
                item: items[1],
                isSelected: currentIndex == 1,
                onTap: () => onIndexChanged(1),
              ),
              // Center action button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: NavBarActionButton(onTap: onActionPressed),
              ),
              // Right side items (Explore, Profile)
              NavBarItem(
                item: items[2],
                isSelected: currentIndex == 2,
                onTap: () => onIndexChanged(2),
              ),
              NavBarItem(
                item: items[3],
                isSelected: currentIndex == 3,
                onTap: () => onIndexChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
