import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';

/// A reusable bottom sheet widget with consistent styling across the app.
///
/// Provides three variants:
/// - [AppBottomSheet.draggable] for scrollable content (like notifications)
/// - [AppBottomSheet.fixed] for fixed-height content (like bio edit)
/// - [AppBottomSheet.persistent] for embedding in a [Stack] (like map overlay)
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
    this.leading,
    this.action,
    this.body,
    this.bodyBuilder,
    this.showDivider = true,
    this.handleKeyboard = true,
    this.isDraggable = false,
    this.isPersistent = false,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.4,
    this.maxChildSize = 0.95,
    this.snap = false,
    this.snapSizes,
  });

  /// Creates a draggable bottom sheet for scrollable content.
  ///
  /// Use this for content that needs to scroll, like notifications or lists.
  /// The [bodyBuilder] returns a list of **sliver** widgets that are placed
  /// inside a [CustomScrollView]. The header is pinned so dragging anywhere
  /// on the sheet (header or body) resizes it.
  ///
  /// When [snap] is true the sheet snaps to [minChildSize], each value in
  /// [snapSizes], and [maxChildSize]. If [snapSizes] is omitted it defaults
  /// to `[initialChildSize]`, giving three snap positions.
  factory AppBottomSheet.draggable({
    required String title,
    Widget? leading,
    Widget? action,
    required List<Widget> Function(ScrollController scrollController) bodyBuilder,
    bool showDivider = true,
    double initialChildSize = 0.7,
    double minChildSize = 0.4,
    double maxChildSize = 0.95,
    bool snap = true,
    List<double>? snapSizes,
  }) {
    return AppBottomSheet._(
      title: title,
      leading: leading,
      action: action,
      bodyBuilder: bodyBuilder,
      showDivider: showDivider,
      isDraggable: true,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: snap,
      snapSizes: snapSizes ?? <double>[initialChildSize],
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

  /// Creates a persistent bottom sheet for embedding in a [Stack].
  ///
  /// Unlike [AppBottomSheet.draggable], this is NOT shown via
  /// [showModalBottomSheet]. Instead, place it directly in a [Stack]
  /// on top of your main content (e.g., a map).
  ///
  /// The sheet can be dragged between [minChildSize] and [maxChildSize],
  /// snapping to [snapSizes] if [snap] is true.
  factory AppBottomSheet.persistent({
    required String title,
    Widget? action,
    required List<Widget> Function(ScrollController scrollController) bodyBuilder,
    bool showDivider = true,
    double initialChildSize = 0.35,
    double minChildSize = 0.15,
    double maxChildSize = 1.0,
    List<double>? snapSizes,
    bool snap = true,
  }) {
    return AppBottomSheet._(
      title: title,
      action: action,
      bodyBuilder: bodyBuilder,
      showDivider: showDivider,
      isPersistent: true,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snapSizes: snapSizes ?? const <double>[0.15, 0.35],
      snap: snap,
    );
  }

  /// The title displayed in the header.
  final String title;

  /// Optional widget displayed on the left side of the header, before the title.
  final Widget? leading;

  /// Optional action widget displayed on the right side of the header.
  final Widget? action;

  /// The body content for fixed sheets.
  final Widget? body;

  /// Builder for sliver body content in draggable and persistent sheets.
  ///
  /// Returns a list of sliver widgets placed inside a [CustomScrollView].
  final List<Widget> Function(ScrollController scrollController)? bodyBuilder;

  /// Whether to show a divider after the header.
  final bool showDivider;

  /// Whether to handle keyboard insets (for fixed sheets only).
  final bool handleKeyboard;

  /// Whether this is a draggable sheet.
  final bool isDraggable;

  /// Whether this is a persistent sheet (embedded in a [Stack]).
  final bool isPersistent;

  /// Initial size for draggable/persistent sheets (0.0 to 1.0).
  final double initialChildSize;

  /// Minimum size for draggable/persistent sheets (0.0 to 1.0).
  final double minChildSize;

  /// Maximum size for draggable/persistent sheets (0.0 to 1.0).
  final double maxChildSize;

  /// Whether the persistent sheet should snap to [snapSizes].
  final bool snap;

  /// Snap positions for persistent sheets (0.0 to 1.0).
  final List<double>? snapSizes;

  @override
  Widget build(BuildContext context) {
    if (isPersistent) {
      return _buildPersistentSheet(context);
    } else if (isDraggable) {
      return _buildDraggableSheet(context);
    } else {
      return _buildFixedSheet(context);
    }
  }

  Widget _buildPersistentSheet(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: snap,
      snapSizes: snapSizes,
      builder: (BuildContext context, ScrollController scrollController) {
        return Material(
          elevation: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: colorScheme.surface,
          clipBehavior: Clip.antiAlias,
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: _SheetHeaderDelegate(
                  title: title,
                  leading: leading,
                  action: action,
                  showDivider: showDivider,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  context: context,
                ),
              ),
              ...bodyBuilder!(scrollController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableSheet(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final EdgeInsets keyboardInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        snap: snap,
        snapSizes: snapSizes,
        builder: (BuildContext context, ScrollController scrollController) {
          return Material(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            color: colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SheetHeaderDelegate(
                    title: title,
                    action: action,
                    showDivider: showDivider,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    context: context,
                  ),
                ),
                ...bodyBuilder!(scrollController),
              ],
            ),
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

/// Delegate for the pinned header in persistent bottom sheets.
class _SheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SheetHeaderDelegate({
    required this.title,
    this.leading,
    this.action,
    required this.showDivider,
    required this.colorScheme,
    required this.textTheme,
    required this.context,
  });

  final String title;
  final Widget? leading;
  final Widget? action;
  final bool showDivider;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final BuildContext context;

  double get _headerHeight {
    // Measure the actual title line height using TextPainter for accuracy.
    final TextStyle titleStyle = (textTheme.headlineSmall ?? const TextStyle(fontSize: 24))
        .copyWith(fontWeight: FontWeight.bold);
    final TextPainter painter = TextPainter(
      text: TextSpan(text: title, style: titleStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final double titleLineHeight = painter.height;
    painter.dispose();

    // drag handle spacing + handle + title padding + title + bottom padding + divider
    return Responsive.h(context, 12) +
        Responsive.h(context, 4) +
        Responsive.h(context, 16) +
        titleLineHeight +
        Responsive.h(context, 12) +
        (showDivider ? 1 : 0);
  }

  @override
  double get minExtent => _headerHeight;

  @override
  double get maxExtent => _headerHeight;

  @override
  bool shouldRebuild(covariant _SheetHeaderDelegate oldDelegate) {
    return title != oldDelegate.title ||
        leading != oldDelegate.leading ||
        action != oldDelegate.action ||
        showDivider != oldDelegate.showDivider;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: Responsive.h(context, 12)),
          Container(
            width: Responsive.w(context, 40),
            height: Responsive.h(context, 4),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 24),
              Responsive.h(context, 16),
              Responsive.w(context, 24),
              Responsive.h(context, 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  SizedBox(width: Responsive.w(context, 12)),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          if (showDivider) const Divider(height: 1),
        ],
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

    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      color: colorScheme.surface,
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
              Responsive.h(context, 12),
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
                if (action != null) action!,
              ],
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
