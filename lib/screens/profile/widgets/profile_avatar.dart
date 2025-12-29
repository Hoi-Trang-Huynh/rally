import 'package:flutter/material.dart';

/// Reusable profile avatar widget with optional online indicator.
///
/// Displays a circular avatar with the user's image or a fallback icon.
/// Can show a green online status indicator dot.
class ProfileAvatar extends StatelessWidget {
  /// Creates a new [ProfileAvatar].
  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.size = 100,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  /// The URL of the avatar image.
  final String? avatarUrl;

  /// The size of the avatar. Defaults to 100.
  final double size;

  /// Whether to show the online indicator.
  final bool showOnlineIndicator;

  /// Whether the user is online.
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primaryContainer),
          child: ClipOval(
            child:
                avatarUrl != null && avatarUrl!.isNotEmpty
                    ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Icon(
                          Icons.person,
                          size: size * 0.5,
                          color: colorScheme.onPrimaryContainer,
                        );
                      },
                    )
                    : Icon(Icons.person, size: size * 0.5, color: colorScheme.onPrimaryContainer),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: size * 0.08,
            bottom: size * 0.08,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? const Color(0xFF22C55E) : colorScheme.outline,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
