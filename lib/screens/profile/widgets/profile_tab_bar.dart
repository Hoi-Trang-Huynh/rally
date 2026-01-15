import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/responsive.dart';

/// Data class for profile tab items.
class ProfileTabData {
  /// Creates a new [ProfileTabData].
  const ProfileTabData({required this.label, required this.id});

  /// The display label for the tab.
  final String label;

  /// Unique identifier for the tab.
  final String id;
}

/// A modular tab bar for the profile screen.
///
/// Supports dynamic tabs with selection state and navigation.
class ProfileTabBar extends StatelessWidget {
  /// Creates a new [ProfileTabBar].
  const ProfileTabBar({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onTabSelected,
  });

  /// List of tab data to display.
  final List<ProfileTabData> tabs;

  /// The currently selected tab ID.
  final String selectedId;

  /// Callback when a tab is selected.
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double containerHeight = Responsive.h(context, 48);

    return Container(
      height: containerHeight,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            tabs.map((ProfileTabData tab) {
              final bool isSelected = tab.id == selectedId;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTabSelected(tab.id);
                  },
                  borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: (textTheme.titleSmall ?? const TextStyle()).copyWith(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: Responsive.h(context, 3),
                        width: isSelected ? Responsive.w(context, 20) : 0,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(Responsive.w(context, 3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
