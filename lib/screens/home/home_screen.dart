import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/screens/home/widgets/home_header.dart';
import 'package:rally/screens/home/widgets/summary_card.dart';
import 'package:rally/utils/responsive.dart';

/// The main home screen of the application.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Builder to access the NestedScrollView's inner scroll controller
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          // Use the primary scroll controller from NestedScrollView
          controller: PrimaryScrollController.of(context),
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            // 1. Header
            const SliverToBoxAdapter(child: HomeHeader()),

            // 2. Summary Cards Grid
            SliverToBoxAdapter(
              child: SizedBox(
                height: Responsive.h(context, 160),
                child: AnimationLimiter(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder:
                          (Widget widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: <Widget>[
                        SizedBox(
                          width: Responsive.w(context, 140),
                          child: const SummaryCard(
                            title: 'Active Rallies',
                            value: '3',
                            icon: Icons.flag_rounded,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 12)),
                        SizedBox(
                          width: Responsive.w(context, 140),
                          child: const SummaryCard(
                            title: 'Places Visited',
                            value: '12',
                            icon: Icons.map_rounded,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 12)),
                        SizedBox(
                          width: Responsive.w(context, 140),
                          child: const SummaryCard(
                            title: 'New Friends',
                            value: '5',
                            icon: Icons.people_rounded,
                            color: Colors.purple,
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 24)), // Spacing for end
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 32))),

            // 3. Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                child: Text(
                  'Recent Activity',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 16))),

            // 4. Placeholder List (Mock Data)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                      vertical: Responsive.h(context, 8),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(Responsive.w(context, 16)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: Responsive.w(context, 48),
                            width: Responsive.w(context, 48),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                            ),
                            child: Icon(
                              Icons.photo_camera_rounded,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                          ),
                          SizedBox(width: Responsive.w(context, 16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Uploaded new photos',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'San Francisco Trip • 2h ago',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    Text(
                                      'San Francisco, CA',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: 10, // Mock 5 items
              ),
            ),

            // Bottom padding for floating nav bar
            SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 100))),
          ],
        );
      },
    );
  }
}
