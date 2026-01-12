import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/nav_item_data.dart';
import '../../utils/responsive.dart';
import 'nav_bar_action_button.dart';
import 'nav_bar_item.dart';

/// The main bottom navigation bar widget for the Rally app.
///
/// Displays navigation items with a floating action button in the center.
/// Uses M3 theme colors and supports both light and dark themes.
/// Includes Glassmorphism and Floating style.
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
    final double borderRadius = Responsive.w(context, 32);
    final double blurSigma = Responsive.w(context, 12);

    assert(items.length == 4, 'AppBottomNavBar requires exactly 4 items');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 12),
        0,
        Responsive.w(context, 12),
        Responsive.h(context, 16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: Responsive.w(context, 16),
              offset: Offset(0, Responsive.h(context, 4)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: Responsive.w(context, 1),
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 8),
                    vertical: Responsive.h(context, 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      // Left side items (Home, Chat)
                      NavBarItem(
                        item: items[0],
                        isSelected: currentIndex == 0,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onIndexChanged(0);
                        },
                      ),
                      NavBarItem(
                        item: items[1],
                        isSelected: currentIndex == 1,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onIndexChanged(1);
                        },
                      ),
                      // Center action button with spacing
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8)),
                        child: NavBarActionButton(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onActionPressed();
                          },
                        ),
                      ),
                      // Right side items (Explore, Profile)
                      NavBarItem(
                        item: items[2],
                        isSelected: currentIndex == 2,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onIndexChanged(2);
                        },
                      ),
                      NavBarItem(
                        item: items[3],
                        isSelected: currentIndex == 3,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onIndexChanged(3);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
