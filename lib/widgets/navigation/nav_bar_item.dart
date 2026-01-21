import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/nav_item_data.dart';
import '../../utils/responsive.dart';

/// A single navigation bar item widget with icon and label.
///
/// Displays an icon above a text label, with different styling
/// for selected (active) and unselected (inactive) states.
/// Uses M3 theme colors for consistent theming.
///
/// Includes haptic feedback and bounce animation.
class NavBarItem extends StatelessWidget {
  /// Creates a new [NavBarItem].
  const NavBarItem({super.key, required this.item, required this.isSelected, required this.onTap});

  /// The navigation item data (icons and label).
  final NavItemData item;

  /// Whether this item is currently selected.
  final bool isSelected;

  /// Callback when this item is tapped.
  final VoidCallback onTap;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: activeColor.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
          child: Center(
            child: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? activeColor : inactiveColor,
                  size:
                      (item.icon == Icons.forum || item.icon == Icons.forum_outlined)
                          ? Responsive.w(context, 28)
                          : Responsive.w(context, 30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
