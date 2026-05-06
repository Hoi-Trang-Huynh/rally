import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/scale_button.dart';

class _CategoryItem {
  const _CategoryItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const List<_CategoryItem> _kDefaultCategories = <_CategoryItem>[
  _CategoryItem(label: 'All', icon: Icons.location_on_rounded),
  _CategoryItem(label: 'Restaurants', icon: Icons.restaurant_rounded),
  _CategoryItem(label: 'Hotels', icon: Icons.hotel_rounded),
  _CategoryItem(label: 'Coffee', icon: Icons.local_cafe_rounded),
  _CategoryItem(label: 'Activities', icon: Icons.local_activity_rounded),
];

/// Horizontal scrollable row of category filter chips for the Explore screen.
class CategoryFilterBar extends StatelessWidget {
  /// Creates a [CategoryFilterBar].
  const CategoryFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Index of the currently selected category.
  final int selectedIndex;

  /// Called when the user taps a category chip.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.h(context, 40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
        itemCount: _kDefaultCategories.length,
        separatorBuilder: (_, __) => SizedBox(width: Responsive.w(context, 8)),
        itemBuilder: (BuildContext context, int index) {
          return _CategoryChip(
            item: _kDefaultCategories[index],
            isSelected: index == selectedIndex,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(index);
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _CategoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 14),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.onSurface : colorScheme.surface,
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
          border: Border.all(
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              item.icon,
              size: Responsive.w(context, 14),
              color: isSelected ? colorScheme.surface : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: Responsive.w(context, 6)),
            Text(
              item.label,
              style: textTheme.labelMedium?.copyWith(
                color: isSelected ? colorScheme.surface : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
