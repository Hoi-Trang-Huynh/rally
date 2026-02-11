import 'package:flutter/material.dart';

/// A reusable [SliverPersistentHeaderDelegate] for sticky tab bars.
///
/// Used by profile screens to pin the tab bar while scrolling.
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  /// The widget to display as the persistent header.
  final Widget child;

  /// The maximum height of the header.
  final double maxHeight;

  /// The minimum height of the header.
  final double minHeight;

  /// Creates a [StickyTabBarDelegate].
  StickyTabBarDelegate({required this.child, required this.maxHeight, required this.minHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent ||
        child != oldDelegate.child;
  }
}
