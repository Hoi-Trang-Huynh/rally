import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A reusable bottom sheet widget with consistent styling across the app.
///
/// Provides two variants:
/// - [AppBottomSheet.draggable] for scrollable content (like notifications)
/// - [AppBottomSheet.fixed] for fixed-height content (like bio edit)
///
/// Common features:
/// - Drag handle at top
/// - Header with title and optional action
/// - Rounded top corners (24px radius)
/// - Surface background color
/// - Consistent responsive padding
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet._({
    required this.title,
    this.action,
    this.body,
    this.bodyBuilder,
    this.showDivider = true,
    this.handleKeyboard = true,
    this.isDraggable = false,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.95,
  });

  /// Creates a draggable bottom sheet for scrollable content.
  ///
  /// Use this for content that needs to scroll, like notifications or lists.
  /// The [bodyBuilder] receives a [ScrollController] that must be attached
  /// to the scrollable widget for proper drag behavior.
  factory AppBottomSheet.draggable({
    required String title,
    Widget? action,
    required Widget Function(ScrollController scrollController) bodyBuilder,
    bool showDivider = true,
    double initialChildSize = 0.7,
    double minChildSize = 0.4,
    double maxChildSize = 0.95,
  }) {
    return AppBottomSheet._(
      title: title,
      action: action,
      bodyBuilder: bodyBuilder,
      showDivider: showDivider,
      isDraggable: true,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
    );
  }

  /// Creates a fixed-height bottom sheet for compact content.
  ///
  /// Use this for forms or content with known height, like bio edit.
  /// Automatically handles keyboard insets when [handleKeyboard] is true.
  factory AppBottomSheet.fixed({
    required String title,
    Widget? action,
    required Widget body,
    bool showDivider = true,
    bool handleKeyboard = true,
  }) {
    return AppBottomSheet._(
      title: title,
      action: action,
      body: body,
      showDivider: showDivider,
      handleKeyboard: handleKeyboard,
      isDraggable: false,
    );
  }

  /// The title displayed in the header.
  final String title;

  /// Optional action widget displayed on the right side of the header.
  final Widget? action;

  /// The body content for fixed sheets.
  final Widget? body;

  /// Builder for the body content in draggable sheets.
  final Widget Function(ScrollController scrollController)? bodyBuilder;

  /// Whether to show a divider after the header.
  final bool showDivider;

  /// Whether to handle keyboard insets (for fixed sheets only).
  final bool handleKeyboard;

  /// Whether this is a draggable sheet.
  final bool isDraggable;

  /// Initial size for draggable sheets (0.0 to 1.0).
  final double initialChildSize;

  /// Minimum size for draggable sheets (0.0 to 1.0).
  final double minChildSize;

  /// Maximum size for draggable sheets (0.0 to 1.0).
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    if (isDraggable) {
      return _buildDraggableSheet(context);
    } else {
      return _buildFixedSheet(context);
    }
  }

  Widget _buildDraggableSheet(BuildContext context) {
    final EdgeInsets keyboardInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return _SheetContainer(
            title: title,
            action: action,
            showDivider: showDivider,
            child: Expanded(child: bodyBuilder!(scrollController)),
          );
        },
      ),
    );
  }

  Widget _buildFixedSheet(BuildContext context) {
    final EdgeInsets keyboardInsets =
        handleKeyboard ? MediaQuery.of(context).viewInsets : EdgeInsets.zero;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInsets.bottom),
      child: _SheetContainer(
        title: title,
        action: action,
        showDivider: showDivider,
        isFixed: true,
        child: body!,
      ),
    );
  }
}

/// Internal container widget that provides the common sheet styling.
class _SheetContainer extends StatelessWidget {
  const _SheetContainer({
    required this.title,
    this.action,
    required this.showDivider,
    required this.child,
    this.isFixed = false,
  });

  final String title;
  final Widget? action;
  final bool showDivider;
  final Widget child;
  final bool isFixed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: isFixed ? MainAxisSize.min : MainAxisSize.max,
        children: <Widget>[
          // Drag Handle
          SizedBox(height: Responsive.h(context, 12)),
          Container(
            width: Responsive.w(context, 40),
            height: Responsive.h(context, 4),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 24),
              Responsive.h(context, 16),
              Responsive.w(context, 24),
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (action != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 24),
                  0,
                  Responsive.w(context, 24),
                  0,
                ),
                child: action!,
              ),
            ),
          if (showDivider) const Divider(height: 1),
          // Body - wrapped in Flexible to prevent overflow
          if (isFixed) Flexible(child: SingleChildScrollView(child: child)) else child,
          // Bottom safe area padding to account for system navigation bar
          if (isFixed)
            SizedBox(height: MediaQuery.paddingOf(context).bottom + Responsive.h(context, 16)),
        ],
      ),
    );
  }
}

/// Helper function to show an [AppBottomSheet] as a modal.
///
/// For draggable sheets, use [backgroundColor] as transparent.
/// For fixed sheets, use the surface color.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required AppBottomSheet sheet,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
}) {
  final bool isDraggable = sheet.isDraggable;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    backgroundColor: isDraggable ? Colors.transparent : null,
    shape:
        isDraggable
            ? null
            : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
    builder: (BuildContext context) => sheet,
  );
}
