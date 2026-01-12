import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    return Container(
      height: 44, // Reduced from 48
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22), // Adjusted radius
      ),
      padding: const EdgeInsets.all(3), // Reduced from 4
      child: Row(
        children:
            tabs.map((ProfileTabData tab) {
              final bool isSelected = tab.id == selectedId;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTabSelected(tab.id);
                  },
                  borderRadius: BorderRadius.circular(19),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ), // Reduced padding
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: (textTheme.titleSmall ?? const TextStyle()).copyWith(
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14, // Reduced from 15
                      ),
                      child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
