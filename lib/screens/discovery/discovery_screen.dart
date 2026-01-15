import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/themes/app_colors.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/glass_container.dart';
import 'package:rally/widgets/common/scale_button.dart';

/// The discovery screen displaying templates and destinations.
///
/// Shows curated travel templates and popular destinations with
/// interactive cards, pull-to-refresh, and bookmark functionality.
class DiscoveryScreen extends StatefulWidget {
  /// Creates a new [DiscoveryScreen].
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  // Track bookmarked templates
  final Set<int> _bookmarkedTemplates = <int>{};

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      HapticFeedback.lightImpact();
    }
  }

  void _toggleBookmark(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_bookmarkedTemplates.contains(index)) {
        _bookmarkedTemplates.remove(index);
      } else {
        _bookmarkedTemplates.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.brandGradientStart,
        backgroundColor: colorScheme.surface,
        strokeWidth: 2.5,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(0, Responsive.h(context, 10), 0, Responsive.h(context, 100)),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (Widget widget) {
                  return SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  );
                },
                children: <Widget>[
                  // Section 1: Templates
                  _buildSectionHeader(
                    context,
                    title: 'Templates',
                    onSeeAll: () {},
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: Responsive.h(context, 16)),
                  SizedBox(
                    height: Responsive.h(context, 300),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                      scrollDirection: Axis.horizontal,
                      itemCount: _templates.length,
                      separatorBuilder: (_, __) => SizedBox(width: Responsive.w(context, 16)),
                      itemBuilder: (BuildContext context, int index) {
                        return _buildTemplateCard(
                          context,
                          _templates[index],
                          index,
                          isBookmarked: _bookmarkedTemplates.contains(index),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: Responsive.h(context, 32)),

                  // Section 2: Destinations
                  _buildSectionHeader(
                    context,
                    title: 'Destinations',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: Responsive.h(context, 16)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                    child: Column(
                      children:
                          _destinations.asMap().entries.map((
                            MapEntry<int, Map<String, dynamic>> entry,
                          ) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: Responsive.h(context, 16)),
                              child: _buildDestinationCard(context, entry.value, entry.key),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onSeeAll,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          if (onSeeAll != null)
            ScaleButton(
              onTap: () {
                HapticFeedback.selectionClick();
                onSeeAll();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'See All',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 4)),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: Responsive.w(context, 16),
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    Map<String, dynamic> template,
    int index, {
    required bool isBookmarked,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to template details
      },
      child: Container(
        width: Responsive.w(context, 220),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Cover Image with Bookmark
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Responsive.w(context, 24)),
                        topRight: Radius.circular(Responsive.w(context, 24)),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(template['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Responsive.w(context, 24)),
                        topRight: Radius.circular(Responsive.w(context, 24)),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Colors.transparent, Colors.black.withValues(alpha: 0.3)],
                      ),
                    ),
                  ),
                  // Bookmark button
                  Positioned(
                    top: Responsive.h(context, 12),
                    right: Responsive.w(context, 12),
                    child: ScaleButton(
                      onTap: () => _toggleBookmark(index),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.w(context, 8)),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            key: ValueKey<bool>(isBookmarked),
                            size: Responsive.w(context, 18),
                            color: isBookmarked ? AppColors.brandGradientEnd : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Use count badge
                  Positioned(
                    bottom: Responsive.h(context, 12),
                    left: Responsive.w(context, 12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 10),
                        vertical: Responsive.h(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.people_alt_rounded,
                            size: Responsive.w(context, 12),
                            color: Colors.white70,
                          ),
                          SizedBox(width: Responsive.w(context, 4)),
                          Text(
                            template['uses'] as String? ?? '1.2k',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          template['title'] as String,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Text(
                          'by ${template['author']}',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${template['rating']}',
                              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Gradient accent indicator
                        Container(
                          width: Responsive.w(context, 40),
                          height: Responsive.h(context, 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: <Color>[
                                AppColors.brandGradientStart,
                                AppColors.brandGradientEnd,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, Map<String, dynamic> dest, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Category data
    final String category = dest['category'] as String? ?? 'Adventure';

    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to destination details
      },
      child: Container(
        height: Responsive.h(context, 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
          image:
              dest['image'] != null
                  ? DecorationImage(image: NetworkImage(dest['image'] as String), fit: BoxFit.cover)
                  : null,
          color: dest['image'] == null ? colorScheme.primaryContainer : null,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (dest['image'] == null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
                  gradient: LinearGradient(
                    colors: <Color>[Colors.purple.shade200, Colors.blue.shade200],
                  ),
                ),
              ),

            // Category badge
            Positioned(
              top: Responsive.h(context, 16),
              left: Responsive.w(context, 16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 12),
                  vertical: Responsive.h(context, 6),
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _getCategoryColor(category).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      _getCategoryIcon(category),
                      size: Responsive.w(context, 12),
                      color: Colors.white,
                    ),
                    SizedBox(width: Responsive.w(context, 4)),
                    Text(
                      category,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Favorite button
            Positioned(
              top: Responsive.h(context, 12),
              right: Responsive.w(context, 16),
              child: ScaleButton(
                onTap: () {
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: EdgeInsets.all(Responsive.w(context, 10)),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: Responsive.w(context, 20),
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Glass container for text content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Responsive.w(context, 24)),
                  bottomRight: Radius.circular(Responsive.w(context, 24)),
                ),
                child: GlassContainer(
                  blur: 12,
                  opacity: 0.15,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Responsive.w(context, 24)),
                    bottomRight: Radius.circular(Responsive.w(context, 24)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          dest['name'] as String,
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 4)),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dest['location'] as String,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return const Color(0xFF9C27B0); // Purple
      case 'adventure':
        return const Color(0xFF4CAF50); // Green
      case 'relaxation':
        return const Color(0xFF03A9F4); // Light Blue
      case 'romantic':
        return const Color(0xFFE91E63); // Pink
      case 'nature':
        return const Color(0xFF8BC34A); // Light Green
      default:
        return const Color(0xFF607D8B); // Blue Grey
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cultural':
        return Icons.temple_buddhist_rounded;
      case 'adventure':
        return Icons.hiking_rounded;
      case 'relaxation':
        return Icons.spa_rounded;
      case 'romantic':
        return Icons.favorite_rounded;
      case 'nature':
        return Icons.forest_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

// Mock Data with enhanced fields
final List<Map<String, dynamic>> _templates = <Map<String, dynamic>>[
  <String, dynamic>{
    'title': 'Paris with friends',
    'author': 'emily_travels',
    'rating': 4.8,
    'uses': '2.4k',
    'color': Colors.pinkAccent,
    'image':
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2673&auto=format&fit=crop',
  },
  <String, dynamic>{
    'title': 'Tokyo Anime Tour',
    'author': 'otaku_guide',
    'rating': 4.9,
    'uses': '5.1k',
    'color': Colors.indigoAccent,
    'image':
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=2694&auto=format&fit=crop',
  },
  <String, dynamic>{
    'title': 'Bali Relax',
    'author': 'yoga_daily',
    'rating': 4.7,
    'uses': '3.8k',
    'color': Colors.teal,
    'image':
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=2676&auto=format&fit=crop',
  },
  <String, dynamic>{
    'title': 'NYC Food Crawl',
    'author': 'foodie_john',
    'rating': 4.5,
    'uses': '1.9k',
    'color': Colors.orange,
    'image':
        'https://images.unsplash.com/photo-1496417263034-38ec4f0d6b21?q=80&w=2670&auto=format&fit=crop',
  },
];

final List<Map<String, dynamic>> _destinations = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': 'Kyoto, Japan',
    'location': 'Kansai Region',
    'category': 'Cultural',
    'image':
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=2670&auto=format&fit=crop',
  },
  <String, dynamic>{
    'name': 'Santorini, Greece',
    'location': 'Aegean Sea',
    'category': 'Romantic',
    'image': 'https://images.pexels.com/photos/1010657/pexels-photo-1010657.jpeg',
  },
  <String, dynamic>{
    'name': 'Banff, Canada',
    'location': 'Alberta',
    'category': 'Nature',
    'image':
        'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?q=80&w=2622&auto=format&fit=crop',
  },
];
