import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import 'settings_screen.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_stats_row.dart';
import 'widgets/profile_tab_bar.dart';

/// The main profile screen displaying user information.
///
/// Shows the user's avatar, username, stats, bio, and achievements.
/// Uses data from [appUserProvider] for available fields.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Creates a new [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedTabId = 'achievements';

  /// Build profile tabs with translations.
  List<ProfileTabData> _buildTabs(Translations t) {
    return <ProfileTabData>[
      ProfileTabData(id: 'achievements', label: t.profile.achievements),
      ProfileTabData(id: 'posts', label: t.profile.posts),
      ProfileTabData(id: 'rallies', label: t.profile.rallies),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> userAsync = ref.watch(appUserProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return userAsync.when(
      data: (AppUser? user) {
        if (user == null) {
          return Center(child: Text(t.profile.notLoggedIn));
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          extendBodyBehindAppBar: true, // Required for glassmorphism
          body: AnimationLimiter(
            child: CustomScrollView(
              slivers: <Widget>[
                // Glassmorphism App Bar
                SliverAppBar(
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.7),
                  elevation: 0,
                  pinned: true,
                  centerTitle: true,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        user.username ?? 'User',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface, size: 20),
                    ],
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Profile Content with Staggered Animation
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (Widget widget) {
                          return SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          );
                        },
                        children: <Widget>[
                          const SizedBox(height: 24), // Standard spacing
                          // Avatar with online indicator
                          ProfileAvatar(
                            avatarUrl: user.avatarUrl,
                            size: 100,
                            showOnlineIndicator: true,
                            isOnline: true,
                          ),

                          const SizedBox(height: 16),

                          // @username
                          Text(
                            '@${user.username ?? 'username'}',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stats row
                          ProfileStatsRow(
                            followersCount: '03',
                            followingCount: '03',
                            followersLabel: t.profile.followers,
                            followingLabel: t.profile.followings,
                          ),

                          const SizedBox(height: 16),

                          // Bio
                          Text(
                            t.profile.bio,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Modular Tab Bar
                          ProfileTabBar(
                            tabs: _buildTabs(t),
                            selectedId: _selectedTabId,
                            onTabSelected: (String id) {
                              setState(() {
                                _selectedTabId = id;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab content
                _buildTabContent(colorScheme),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (Object error, StackTrace stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildTabContent(ColorScheme colorScheme) {
    switch (_selectedTabId) {
      case 'achievements':
        return _buildPlaceholderGrid(colorScheme, 6);
      case 'posts':
        return _buildPlaceholderGrid(colorScheme, 9);
      case 'rallies':
        return _buildPlaceholderGrid(colorScheme, 3);
      default:
        return _buildPlaceholderGrid(colorScheme, 6);
    }
  }

  Widget _buildPlaceholderGrid(ColorScheme colorScheme, int count) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }, childCount: count),
      ),
    );
  }
}
