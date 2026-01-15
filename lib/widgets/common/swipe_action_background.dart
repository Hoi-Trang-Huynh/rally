import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A background widget for swipe-to-action gestures in Dismissible widgets.
///
/// Displays an icon and label with a colored background.
class SwipeActionBackground extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// The background color.
  final Color color;

  /// Whether this is the left (primary) or right (secondary) background.
  final bool isLeft;

  /// Creates a new [SwipeActionBackground].
  const SwipeActionBackground({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isLeft,
  });

  /// Creates a pin action background.
  factory SwipeActionBackground.pin({Key? key, required bool isLeft}) {
    return SwipeActionBackground(
      key: key,
      icon: Icons.push_pin_rounded,
      label: 'Pin',
      color: const Color(0xFF2196F3), // Blue
      isLeft: isLeft,
    );
  }

  /// Creates an archive action background.
  factory SwipeActionBackground.archive({Key? key, required bool isLeft}) {
    return SwipeActionBackground(
      key: key,
      icon: Icons.archive_rounded,
      label: 'Archive',
      color: const Color(0xFF9E9E9E), // Grey
      isLeft: isLeft,
    );
  }

  /// Creates a mute action background.
  factory SwipeActionBackground.mute({Key? key, required bool isLeft}) {
    return SwipeActionBackground(
      key: key,
      icon: Icons.notifications_off_rounded,
      label: 'Mute',
      color: const Color(0xFFFF9800), // Orange
      isLeft: isLeft,
    );
  }

  /// Creates a delete action background.
  factory SwipeActionBackground.delete({Key? key, required bool isLeft}) {
    return SwipeActionBackground(
      key: key,
      icon: Icons.delete_rounded,
      label: 'Delete',
      color: const Color(0xFFF44336), // Red
      isLeft: isLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      ),
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!isLeft) ...<Widget>[
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: Responsive.w(context, 14),
              ),
            ),
            SizedBox(width: Responsive.w(context, 8)),
          ],
          Icon(icon, color: Colors.white, size: Responsive.w(context, 24)),
          if (isLeft) ...<Widget>[
            SizedBox(width: Responsive.w(context, 8)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: Responsive.w(context, 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
