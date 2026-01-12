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
    final TextTheme textTheme = Theme.of(context).textTheme;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Bounce animation for icon
              AnimatedScale(
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
                    size: Responsive.w(context, 24),
                  ),
                ),
              ),
              SizedBox(height: Responsive.h(context, 4)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              // Optional: Small dot indicator
              SizedBox(height: Responsive.h(context, 4)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: Responsive.w(context, 4),
                width: isSelected ? Responsive.w(context, 4) : 0,
                decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
