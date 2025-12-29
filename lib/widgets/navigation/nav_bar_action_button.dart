import 'package:flutter/material.dart';

/// The central floating action button for the bottom navigation bar.
///
/// A circular button with the primary theme color that floats
/// above the navigation bar. Typically used for a primary action
/// like creating new content.
class NavBarActionButton extends StatelessWidget {
  /// Creates a new [NavBarActionButton].
  const NavBarActionButton({super.key, required this.onTap, this.icon = Icons.add, this.size = 56});

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// The icon to display. Defaults to [Icons.add].
  final IconData icon;

  /// The size of the button. Defaults to 56.
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onPrimary, size: 28),
      ),
    );
  }
}
