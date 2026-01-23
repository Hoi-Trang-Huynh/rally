import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/models/responses/follow_status_response.dart';
import 'package:rally/models/responses/user_public_profile_response.dart';
import 'package:rally/providers/user_provider.dart';
import 'package:rally/screens/profile/widgets/profile_content.dart';
import 'package:rally/screens/profile/widgets/profile_tab_bar.dart';
import 'package:rally/services/user_repository.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/empty_state.dart';
import 'package:rally/widgets/common/shimmer_loading.dart';
import 'package:rally/widgets/navigation/secondary_shell.dart';

import '../../i18n/generated/translations.g.dart';
import 'widgets/follow_list_sheet.dart';

/// Screen to display another user's public profile.
///
/// This is a standalone screen (outside the main shell) with its own minimal
/// AppBar containing just a back button. Supports stack-based navigation.
class UserProfileScreen extends ConsumerStatefulWidget {
  /// The ID of the user to display.
  final String userId;

  /// Creates a new [UserProfileScreen].
  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  String _selectedTabId = 'posts';
  bool _isFollowLoading = false;

  List<ProfileTabData> _buildTabs(Translations t) {
    return <ProfileTabData>[
      ProfileTabData(id: 'posts', label: t.profile.posts),
      ProfileTabData(id: 'rallies', label: t.profile.rallies),
    ];
  }

  /// Handle follow/unfollow action.
  Future<void> _handleFollowAction(bool isCurrentlyFollowing) async {
    if (_isFollowLoading) return;

    setState(() => _isFollowLoading = true);

    try {
      final UserRepository userRepository = ref.read(userRepositoryProvider);

      if (isCurrentlyFollowing) {
        await userRepository.unfollowUser(widget.userId);
      } else {
        await userRepository.followUser(widget.userId);
      }

      // Invalidate both providers to refetch fresh data
      ref.invalidate(followStatusProvider(widget.userId));
      ref.invalidate(userProfileProvider(widget.userId));
    } catch (e) {
      if (mounted) {
        final Translations t = Translations.of(context);
        final String errorMessage =
            isCurrentlyFollowing
                ? t.profile.errorUnfollow(error: e)
                : t.profile.errorFollow(error: e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  /// Build the follow/unfollow button based on follow status.
  Widget _buildFollowButton(
    BuildContext context,
    AsyncValue<FollowStatusResponse> followStatusAsync,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return followStatusAsync.when(
      data: (FollowStatusResponse status) {
        final bool isFollowing = status.isFollowing;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: Responsive.h(context, 44),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            color: isFollowing ? colorScheme.surfaceContainerHighest : colorScheme.primary,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleFollowAction(isFollowing),
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              child: Center(
                child:
                    _isFollowLoading
                        ? SizedBox(
                          width: Responsive.w(context, 20),
                          height: Responsive.w(context, 20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
                          ),
                        )
                        : Text(
                          isFollowing ? t.profile.following : t.profile.follow,
                          style: textTheme.labelLarge?.copyWith(
                            color: isFollowing ? colorScheme.onSurface : colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
              ),
            ),
          ),
        );
      },
      loading:
          () => ShimmerLoading(
            width: double.infinity,
            height: Responsive.h(context, 44),
            borderRadius: 12,
          ),
      error:
          (_, __) => SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => ref.invalidate(followStatusProvider(widget.userId)),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(t.common.retry),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserPublicProfileResponse> userProfileAsync = ref.watch(
      userProfileProvider(widget.userId),
    );
    final AsyncValue<FollowStatusResponse> followStatusAsync = ref.watch(
      followStatusProvider(widget.userId),
    );
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Translations t = Translations.of(context);

    // Get username for AppBar title (if loaded)
    final String? username = userProfileAsync.valueOrNull?.username;

    return SecondaryShell(
      title: username != null ? '@$username' : null,
      body: userProfileAsync.when(
        data: (UserPublicProfileResponse profile) {
          final ProfileData profileData = ProfileData.fromPublicProfile(profile);

          return AnimationLimiter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                // Profile Content (no SafeArea needed, AppBar handles it)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                    child: AnimationConfiguration.synchronized(
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ProfileContent(
                            data: profileData,
                            onEditProfile: null,
                            onEditBio: null,
                            primaryButton: _buildFollowButton(context, followStatusAsync),
                            onFollowersTap:
                                () => showFollowListSheet(
                                  context: context,
                                  userId: widget.userId,
                                  initialTab: FollowListTab.followers,
                                ),
                            onFollowingTap:
                                () => showFollowListSheet(
                                  context: context,
                                  userId: widget.userId,
                                  initialTab: FollowListTab.following,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 12))),

                // Sticky Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: Container(
                      color: colorScheme.surface,
                      padding: EdgeInsets.only(bottom: Responsive.h(context, 16)),
                      child: ProfileTabBar(
                        tabs: _buildTabs(t),
                        selectedId: _selectedTabId,
                        onTabSelected: (String id) {
                          setState(() {
                            _selectedTabId = id;
                          });
                        },
                      ),
                    ),
                    maxHeight: Responsive.h(context, 60),
                    minHeight: Responsive.h(context, 60),
                  ),
                ),

                // Tab content placeholder
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: Responsive.h(context, 100)),
                    child: EmptyState(
                      icon:
                          _selectedTabId == 'posts'
                              ? Icons.format_quote_outlined
                              : Icons.map_outlined,
                      title: _selectedTabId == 'posts' ? t.profile.noPosts : t.profile.noRallies,
                      subtitle:
                          _selectedTabId == 'posts'
                              ? t.profile.noPostsSubtitle
                              : t.profile.noRalliesSubtitle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading:
            () => Center(
              child: ShimmerLoading(
                width: Responsive.w(context, 200),
                height: Responsive.h(context, 200),
                borderRadius: 16,
              ),
            ),
        error:
            (Object error, StackTrace stack) => Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(context, 24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    SizedBox(height: Responsive.h(context, 16)),
                    Text(
                      t.common.errorLoadingProfile,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    Text(
                      error.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.h(context, 16)),
                    FilledButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(t.common.goBack),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}

/// Helper delegate for sticky tab bar.
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _StickyTabBarDelegate({required this.child, required this.maxHeight, required this.minHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent ||
        child != oldDelegate.child;
  }
}
