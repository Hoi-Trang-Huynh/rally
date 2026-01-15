import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_user.dart';
import '../../../../utils/responsive.dart';
import 'profile_avatar.dart';

/// A modern header for the profile screen.
///
/// Displays the user's avatar, name, username, and an edit button.
class ProfileHeader extends ConsumerWidget {
  /// Creates a modern header for the profile screen.
  const ProfileHeader({super.key, required this.user, required this.onEditProfile});

  /// The user to display.
  final AppUser user;

  /// Callback when the edit profile button is tapped.
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Variable 't' removed as it was unused.
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        // Avatar
        ProfileAvatar(
          avatarUrl: user.avatarUrl,
          baseSize: 100,
          showOnlineIndicator: false, // Clean look, maybe re-enable later if needed
          borderWidth: 4,
          borderColor: colorScheme.surface, // Blend with background
        ),

        // Name
        if (user.firstName != null || user.lastName != null)
          Padding(
            padding: EdgeInsets.only(bottom: Responsive.h(context, 4)),
            child: Text(
              '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Username
        Text(
          '@${user.username}',
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
