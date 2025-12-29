import 'package:flutter/material.dart';

import '../../models/nav_item_data.dart';

/// A single navigation bar item widget with icon and label.
///
/// Displays an icon above a text label, with different styling
/// for selected (active) and unselected (inactive) states.
/// Uses M3 theme colors for consistent theming.
class NavBarItem extends StatelessWidget {
  /// Creates a new [NavBarItem].
  const NavBarItem({super.key, required this.item, required this.isSelected, required this.onTap});

  /// The navigation item data (icons and label).
  final NavItemData item;

  /// Whether this item is currently selected.
  final bool isSelected;

  /// Callback when this item is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: textTheme.labelSmall?.copyWith(
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
