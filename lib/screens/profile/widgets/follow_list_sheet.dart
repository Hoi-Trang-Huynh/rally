import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/responses/follow_list_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/common/shimmer_loading.dart';

import 'profile_avatar.dart';

/// The initial tab to display in the follow list sheet.
enum FollowListTab {
  /// Show followers list.
  followers,

  /// Show following list.
  following,
}

/// A bottom sheet displaying followers and following lists with tabs.
///
/// Features:
/// - Tab bar switching between Followers and Following
/// - Paginated lists with infinite scroll
/// - Empty states for each tab
/// - Tappable user tiles that navigate to user profiles
class FollowListSheet extends ConsumerStatefulWidget {
  /// Creates a [FollowListSheet].
  const FollowListSheet({super.key, required this.userId, required this.initialTab});

  /// The user ID to fetch followers/following for.
  final String userId;

  /// The initial tab to display.
  final FollowListTab initialTab;

  @override
  ConsumerState<FollowListSheet> createState() => _FollowListSheetState();
}

class _FollowListSheetState extends ConsumerState<FollowListSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Followers state
  List<FollowUserItem> _followers = <FollowUserItem>[];
  bool _isLoadingFollowers = true;
  bool _hasMoreFollowers = true;
  int _followersPage = 1;

  // Following state
  List<FollowUserItem> _following = <FollowUserItem>[];
  bool _isLoadingFollowing = true;
  bool _hasMoreFollowing = true;
  int _followingPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == FollowListTab.followers ? 0 : 1,
    );
    _loadFollowers();
    _loadFollowing();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowers({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoadingFollowers = true;
        _followersPage = 1;
      });
    }

    try {
      final FollowListResponse response = await ref
          .read(userRepositoryProvider)
          .getFollowers(userId: widget.userId, page: _followersPage);

      if (mounted) {
        setState(() {
          if (loadMore) {
            _followers.addAll(response.users);
          } else {
            _followers = response.users;
          }
          _hasMoreFollowers = _followersPage < response.totalPages;
          _isLoadingFollowers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFollowers = false);
      }
    }
  }

  Future<void> _loadFollowing({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoadingFollowing = true;
        _followingPage = 1;
      });
    }

    try {
      final FollowListResponse response = await ref
          .read(userRepositoryProvider)
          .getFollowing(userId: widget.userId, page: _followingPage);

      if (mounted) {
        setState(() {
          if (loadMore) {
            _following.addAll(response.users);
          } else {
            _following = response.users;
          }
          _hasMoreFollowing = _followingPage < response.totalPages;
          _isLoadingFollowing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFollowing = false);
      }
    }
  }

  void _loadMoreFollowers() {
    if (!_isLoadingFollowers && _hasMoreFollowers) {
      _followersPage++;
      _loadFollowers(loadMore: true);
    }
  }

  void _loadMoreFollowing() {
    if (!_isLoadingFollowing && _hasMoreFollowing) {
      _followingPage++;
      _loadFollowing(loadMore: true);
    }
  }

  void _onUserTap(FollowUserItem user) {
    HapticFeedback.lightImpact();
    Navigator.of(context, rootNavigator: true).pop();

    // Check if tapping on current user
    final String? currentUserId = ref.read(appUserProvider).valueOrNull?.id;
    final bool isMe = currentUserId != null && currentUserId == user.id;

    if (isMe) {
      // Navigate to own profile tab
      context.go(AppRoutes.profile);
    } else {
      // Push to user profile (maintains back stack)
      context.push(AppRoutes.userProfile(user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return AppBottomSheet.draggable(
      title:
          widget.initialTab == FollowListTab.followers
              ? t.profile.followersTitle
              : t.profile.followingTitle,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      bodyBuilder: (ScrollController scrollController) {
        return Column(
          children: <Widget>[
            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 24),
                vertical: Responsive.h(context, 8),
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: textTheme.labelLarge,
                padding: EdgeInsets.all(Responsive.w(context, 4)),
                tabs: <Widget>[
                  Tab(text: t.profile.followersTitle),
                  Tab(text: t.profile.followingTitle),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  _buildFollowersList(scrollController, t),
                  _buildFollowingList(scrollController, t),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFollowersList(ScrollController scrollController, Translations t) {
    if (_isLoadingFollowers && _followers.isEmpty) {
      return _buildLoadingList();
    }

    if (_followers.isEmpty) {
      return _buildEmptyState(t.profile.noFollowers);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification && notification.metrics.extentAfter < 200) {
          _loadMoreFollowers();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: Responsive.h(context, 24)),
        itemCount: _followers.length + (_hasMoreFollowers ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index >= _followers.length) {
            return _buildLoadingIndicator();
          }
          return _FollowUserTile(
            user: _followers[index],
            onTap: () => _onUserTap(_followers[index]),
          );
        },
      ),
    );
  }

  Widget _buildFollowingList(ScrollController scrollController, Translations t) {
    if (_isLoadingFollowing && _following.isEmpty) {
      return _buildLoadingList();
    }

    if (_following.isEmpty) {
      return _buildEmptyState(t.profile.noFollowing);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification && notification.metrics.extentAfter < 200) {
          _loadMoreFollowing();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: Responsive.h(context, 24)),
        itemCount: _following.length + (_hasMoreFollowing ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index >= _following.length) {
            return _buildLoadingIndicator();
          }
          return _FollowUserTile(
            user: _following[index],
            onTap: () => _onUserTap(_following[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 24),
            vertical: Responsive.h(context, 8),
          ),
          child: Row(
            children: <Widget>[
              ShimmerLoading(
                width: Responsive.w(context, 48),
                height: Responsive.w(context, 48),
                borderRadius: Responsive.w(context, 24),
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ShimmerLoading(
                      width: Responsive.w(context, 120),
                      height: Responsive.h(context, 14),
                      borderRadius: 4,
                    ),
                    SizedBox(height: Responsive.h(context, 4)),
                    ShimmerLoading(
                      width: Responsive.w(context, 80),
                      height: Responsive.h(context, 12),
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.people_outline_rounded,
              size: Responsive.w(context, 64),
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

/// A tile displaying a user in the follow list.
class _FollowUserTile extends StatelessWidget {
  const _FollowUserTile({required this.user, required this.onTap});

  final FollowUserItem user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 24),
          vertical: Responsive.h(context, 10),
        ),
        child: Row(
          children: <Widget>[
            // Avatar
            ProfileAvatar(avatarUrl: user.avatarUrl, baseSize: 48, showOnlineIndicator: false),
            SizedBox(width: Responsive.w(context, 12)),
            // Name and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.displayName,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(context, 2)),
                  Text(
                    '@${user.username}',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: Responsive.w(context, 24),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the follow list bottom sheet.
void showFollowListSheet({
  required BuildContext context,
  required String userId,
  required FollowListTab initialTab,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => FollowListSheet(userId: userId, initialTab: initialTab),
  );
}
