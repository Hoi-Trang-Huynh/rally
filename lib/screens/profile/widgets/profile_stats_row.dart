import 'package:flutter/material.dart';
import 'package:rally/widgets/visuals/animated_count.dart';

/// A widget displaying a single stat with count and label.
///
/// Used in the profile stats row to show followers/following counts.
class ProfileStatItem extends StatelessWidget {
  /// Creates a new [ProfileStatItem].
  const ProfileStatItem({super.key, required this.count, required this.label, this.onTap});

  /// The numeric count to display.
  final String count;

  /// The label text below the count.
  final String label;

  /// Optional callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedCount(
              count: count,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// A row displaying followers and following counts.
class ProfileStatsRow extends StatelessWidget {
  /// Creates a new [ProfileStatsRow].
  const ProfileStatsRow({
    super.key,
    required this.followersCount,
    required this.followingCount,
    required this.followersLabel,
    required this.followingLabel,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  /// The followers count to display.
  final String followersCount;

  /// The following count to display.
  final String followingCount;

  /// The label for followers.
  final String followersLabel;

  /// The label for following.
  final String followingLabel;

  /// Callback when followers is tapped.
  final VoidCallback? onFollowersTap;

  /// Callback when following is tapped.
  final VoidCallback? onFollowingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ProfileStatItem(count: followersCount, label: followersLabel, onTap: onFollowersTap),
        const SizedBox(width: 16),
        ProfileStatItem(count: followingCount, label: followingLabel, onTap: onFollowingTap),
      ],
    );
  }
}
