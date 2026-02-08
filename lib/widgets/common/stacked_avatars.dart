import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A widget that displays a stack of overlapping circular avatars.
///
/// Shows up to [maxVisible] avatars with an optional "+N" overflow indicator.
/// When [items] is empty, displays an [emptyPlaceholder] or a default add icon.
class StackedAvatars extends StatelessWidget {
  /// Creates a [StackedAvatars] widget.
  const StackedAvatars({
    super.key,
    required this.items,
    this.maxVisible = 3,
    this.avatarRadius = 20,
    this.overlapFactor = 0.7,
    this.emptyPlaceholder,
    this.onTap,
  });

  /// The list of avatar items to display.
  final List<StackedAvatarItem> items;

  /// Maximum number of avatars to show before showing "+N".
  final int maxVisible;

  /// Radius of each avatar circle.
  final double avatarRadius;

  /// How much avatars overlap (0.0 = no overlap, 1.0 = full overlap).
  /// Default is 0.7 meaning 70% of avatar diameter as offset.
  final double overlapFactor;

  /// Widget to show when [items] is empty.
  /// Defaults to a circle with a person-add icon.
  final Widget? emptyPlaceholder;

  /// Callback when the stack is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double diameter = Responsive.w(context, avatarRadius * 2);
    final double offset = diameter * overlapFactor;
    final int displayCount = items.length.clamp(0, maxVisible);
    final int overflowCount = items.length - maxVisible;
    final bool hasOverflow = overflowCount > 0;

    // Calculate total width needed
    final double totalWidth =
        items.isEmpty ? diameter : diameter + (displayCount - 1 + (hasOverflow ? 1 : 0)) * offset;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: totalWidth,
        height: diameter,
        child:
            items.isEmpty
                ? emptyPlaceholder ?? _buildDefaultEmptyPlaceholder(context)
                : Stack(
                  children: <Widget>[
                    for (int i = 0; i < displayCount; i++)
                      Positioned(
                        left: i * offset,
                        child: _buildAvatar(context, items[i], diameter, colorScheme, textTheme),
                      ),
                    if (hasOverflow)
                      Positioned(
                        left: displayCount * offset,
                        child: Container(
                          width: diameter,
                          height: diameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.surfaceContainerHighest,
                            border: Border.all(color: colorScheme.surface, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '+$overflowCount',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildDefaultEmptyPlaceholder(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double diameter = Responsive.w(context, avatarRadius * 2);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Icon(
        Icons.person_add_outlined,
        size: Responsive.w(context, avatarRadius),
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    StackedAvatarItem item,
    double diameter,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
        border: Border.all(color: colorScheme.surface, width: 2),
        image:
            item.imageUrl != null
                ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                : null,
      ),
      child:
          item.imageUrl == null
              ? Center(
                child: Text(
                  item.fallbackText?.isNotEmpty == true ? item.fallbackText![0].toUpperCase() : '?',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : null,
    );
  }
}

/// Data class representing a single avatar item.
class StackedAvatarItem {
  /// Creates a [StackedAvatarItem].
  const StackedAvatarItem({required this.id, this.imageUrl, this.fallbackText});

  /// Unique identifier for this avatar.
  final String id;

  /// URL of the avatar image.
  final String? imageUrl;

  /// Text to use as fallback when [imageUrl] is null.
  /// First character will be displayed.
  final String? fallbackText;
}
