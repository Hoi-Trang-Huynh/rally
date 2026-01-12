import 'package:flutter/material.dart';

/// A widget that animates a number from 0 to the target value.
class AnimatedCount extends StatelessWidget {
  /// The target number to display.
  /// Can be a clean integer string or a formatted string (will try to parse).
  final String count;

  /// The text style to apply.
  final TextStyle? style;

  /// Duration of the counting animation.
  final Duration duration;

  /// Creates a new [AnimatedCount].
  const AnimatedCount({
    super.key,
    required this.count,
    this.style,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    // Try to parse the int, removing non-digits
    final int? targetValue = int.tryParse(count.replaceAll(RegExp(r'[^0-9]'), ''));

    // If parsing fails, just return text without animation
    if (targetValue == null) {
      return Text(count, style: style);
    }

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: targetValue),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (BuildContext context, int value, Widget? child) {
        // Pad with leading zero if original had it (simple heuristic for '03')
        final String display =
            count.startsWith('0') && value < 10 && count.length == 2 ? '0$value' : value.toString();

        return Text(display, style: style);
      },
    );
  }
}
