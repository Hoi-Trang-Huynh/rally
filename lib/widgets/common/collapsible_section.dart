import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A reusable collapsible section with a header and expandable content.
class CollapsibleSection extends StatelessWidget {
  /// Creates a [CollapsibleSection].
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  /// The title text displayed in the header.
  final String title;

  /// Whether the section is currently expanded.
  final bool isExpanded;

  /// Callback when the header is tapped to toggle expansion.
  final VoidCallback onToggle;

  /// The content to reveal when expanded.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header (tappable)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
                vertical: Responsive.h(context, 14),
              ),
              child: Row(
                children: <Widget>[
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: Responsive.w(context, 20),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 8)),
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content (expandable)
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(
                left: Responsive.w(context, 16),
                right: Responsive.w(context, 16),
                bottom: Responsive.h(context, 12),
              ),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
