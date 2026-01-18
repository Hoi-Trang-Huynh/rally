import 'package:flutter/material.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/models/responses/user_public_profile_response.dart';
import 'package:rally/utils/responsive.dart';

import '../../../i18n/generated/translations.g.dart';
import 'profile_avatar.dart';
import 'profile_bio.dart';
import 'profile_stats_row.dart';

/// Data class to hold profile data from different sources.
class ProfileData {
  /// The user's unique ID.
  final String? id;

  /// The user's username.
  final String? username;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The URL of the user's avatar.
  final String? avatarUrl;

  /// The user's bio text.
  final String? bioText;

  /// The number of followers.
  final int followersCount;

  /// The number of users being followed.
  final int followingCount;

  /// Whether this is the current user's own profile.
  final bool isOwnProfile;

  /// Creates a new [ProfileData].
  const ProfileData({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.bioText,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isOwnProfile = false,
  });

  /// Creates ProfileData from AppUser (current user).
  factory ProfileData.fromAppUser(AppUser user) {
    return ProfileData(
      id: user.id,
      username: user.username,
      firstName: user.firstName,
      lastName: user.lastName,
      avatarUrl: user.avatarUrl,
      bioText: user.bioText,
      followersCount: 0, // Fetched separately for current user
      followingCount: 0,
      isOwnProfile: true,
    );
  }

  /// Creates ProfileData from UserPublicProfileResponse (other user).
  factory ProfileData.fromPublicProfile(UserPublicProfileResponse profile) {
    return ProfileData(
      id: profile.id,
      username: profile.username,
      firstName: profile.firstName,
      lastName: profile.lastName,
      avatarUrl: profile.avatarUrl,
      bioText: profile.bioText,
      followersCount: profile.followersCount,
      followingCount: profile.followingCount,
      isOwnProfile: false,
    );
  }
}

/// Shared profile content widget used by both ProfileScreen and UserProfileScreen.
///
/// Displays avatar, name, username, stats, and bio in a consistent layout.
class ProfileContent extends StatelessWidget {
  /// The profile data to display.
  final ProfileData data;

  /// Optional bio text override (for current user where bio is fetched separately).
  final String? overrideBioText;

  /// Whether the bio is currently loading.
  final bool isBioLoading;

  /// Callback when the edit profile button is tapped.
  final VoidCallback? onEditProfile;

  /// Callback when the bio edit button is tapped.
  final VoidCallback? onEditBio;

  /// Optional action button widget (e.g., Follow/Unfollow button for other users).
  final Widget? actionButton;

  /// Optional primary button widget (displayed below bio).
  final Widget? primaryButton;

  /// Creates a new [ProfileContent].
  const ProfileContent({
    super.key,
    required this.data,
    this.overrideBioText,
    this.isBioLoading = false,
    this.onEditProfile,
    this.onEditBio,
    this.actionButton,
    this.primaryButton,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    final String? displayBio = overrideBioText ?? data.bioText;

    return Stack(
      children: <Widget>[
        // Main content column
        Column(
          children: <Widget>[
            SizedBox(height: Responsive.h(context, 24)),
            // Avatar
            ProfileAvatar(
              avatarUrl: data.avatarUrl,
              baseSize: 100,
              showOnlineIndicator: false,
              borderWidth: 4,
              borderColor: colorScheme.surface,
            ),

            // Name
            if (data.firstName != null || data.lastName != null)
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(context, 4)),
                child: Text(
                  '${data.firstName ?? ''} ${data.lastName ?? ''}'.trim(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Username
            Text(
              '@${data.username ?? 'unknown'}',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: Responsive.h(context, 12)),

            // Stats
            ProfileStatsRow(
              followersCount: data.followersCount.toString(),
              followingCount: data.followingCount.toString(),
              followersLabel: t.profile.followers,
              followingLabel: t.profile.followings,
            ),

            SizedBox(height: Responsive.h(context, 12)),

            // Bio
            ProfileBio(bioText: displayBio, onEdit: onEditBio, isLoading: isBioLoading),

            if (primaryButton != null) ...<Widget>[
              SizedBox(height: Responsive.h(context, 24)),
              primaryButton!,
            ],
          ],
        ),

        // Action button positioned at top-right (Instagram style)
        if (actionButton != null)
          Positioned(
            top: Responsive.h(context, 16),
            right: 0,
            child: UnconstrainedBox(child: actionButton!),
          ),
      ],
    );
  }
}
