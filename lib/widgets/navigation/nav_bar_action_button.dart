import 'package:flutter/material.dart';

import '../../utils/responsive.dart';

/// The central floating action button for the bottom navigation bar.
///
/// A circular button with the primary theme color that floats
/// above the navigation bar. Typically used for a primary action
/// like creating new content.
class NavBarActionButton extends StatelessWidget {
  /// Creates a new [NavBarActionButton].
  const NavBarActionButton({
    super.key,
    required this.onTap,
    this.icon = Icons.add,
    this.baseSize = 56,
  });

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// The icon to display. Defaults to [Icons.add].
  final IconData icon;

  /// The base size of the button (before responsive scaling). Defaults to 56.
  final double baseSize;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double size = Responsive.w(context, baseSize);

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
              color: colorScheme.shadow.withValues(alpha: 0.25),
              blurRadius: Responsive.w(context, 8),
              offset: Offset(0, Responsive.h(context, 4)),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onPrimary, size: Responsive.w(context, 28)),
      ),
    );
  }
}
