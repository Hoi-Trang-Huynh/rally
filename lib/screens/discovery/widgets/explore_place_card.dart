import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rally/themes/app_colors.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/scale_button.dart';

/// A card displaying a place in the Explore bottom sheet list.
///
/// Shows the place thumbnail, name, rating, price, hours, and distance.
/// The bookmark icon triggers [onBookmark]; tapping the card body calls [onTap].
class ExplorePlaceCard extends StatelessWidget {
  /// Creates an [ExplorePlaceCard].
  const ExplorePlaceCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.hours,
    required this.distance,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmark,
  });

  /// Display name of the place.
  final String name;

  /// URL for the place thumbnail image.
  final String imageUrl;

  /// Average rating (e.g. 4.4).
  final double rating;

  /// Total number of reviews.
  final int reviewCount;

  /// Price label shown next to rating (e.g. "Free", "VND 40k").
  final String price;

  /// Operating hours label (e.g. "Open 24h").
  final String hours;

  /// Distance from user (e.g. "1.2 km").
  final String distance;

  /// Whether the place is already bookmarked.
  final bool isBookmarked;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Called when the bookmark icon is tapped.
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 20),
          vertical: Responsive.h(context, 10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              child: Image.network(
                imageUrl,
                width: Responsive.w(context, 76),
                height: Responsive.w(context, 76),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: Responsive.w(context, 76),
                  height: Responsive.w(context, 76),
                  color: colorScheme.surfaceContainer,
                  child: Icon(
                    Icons.image_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: Responsive.w(context, 28),
                  ),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 14)),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.star_rounded,
                        size: Responsive.w(context, 14),
                        color: Colors.amber,
                      ),
                      SizedBox(width: Responsive.w(context, 3)),
                      Text(
                        '$rating (${_formatCount(reviewCount)})',
                        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '  ·  $price',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 5)),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time_rounded,
                        size: Responsive.w(context, 12),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: Responsive.w(context, 3)),
                      Text(
                        hours,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 10)),
                      Icon(
                        Icons.location_on_rounded,
                        size: Responsive.w(context, 12),
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: Responsive.w(context, 3)),
                      Text(
                        distance,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bookmark button
            ScaleButton(
              onTap: () {
                HapticFeedback.selectionClick();
                onBookmark?.call();
              },
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(context, 4)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    key: ValueKey<bool>(isBookmarked),
                    size: Responsive.w(context, 22),
                    color: isBookmarked
                        ? AppColors.brandGradientStart
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }
}
