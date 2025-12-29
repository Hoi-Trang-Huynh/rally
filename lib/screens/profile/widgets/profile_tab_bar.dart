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

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 24),
        itemBuilder: (BuildContext context, int index) {
          final ProfileTabData tab = tabs[index];
          final bool isSelected = tab.id == selectedId;

          return InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTabSelected(tab.id);
            },
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(tab.label),
              ),
            ),
          );
        },
      ),
    );
  }
}
