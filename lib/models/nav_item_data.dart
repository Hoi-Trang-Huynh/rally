import 'package:flutter/material.dart';

/// Data class representing a navigation bar item.
///
/// Contains the visual properties (icons, label) and routing information
/// for each navigation destination in the bottom nav bar.
class NavItemData {
  /// Creates a new [NavItemData].
  const NavItemData({required this.icon, required this.activeIcon, required this.label});

  /// The icon displayed when this item is not selected.
  final IconData icon;

  /// The icon displayed when this item is selected.
  final IconData activeIcon;

  /// The label text displayed below the icon.
  final String label;
}
