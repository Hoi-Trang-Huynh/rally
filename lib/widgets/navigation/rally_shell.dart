import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/utils/responsive.dart';

/// A shell wrapper for rally-related screens.
///
/// Provides a consistent AppBar with:
/// - Back button (navigates to /home by default)
/// - Optional title
/// - Optional trailing actions
///
/// Similar to [SecondaryShell] but tailored for rally context
/// with custom back navigation and potential rally-specific chrome.
class RallyShell extends StatelessWidget {
  /// Creates a [RallyShell].
  const RallyShell({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.centerTitle = true,
  });

  /// The main content of the screen.
  final Widget body;

  /// Optional title string displayed in the AppBar.
  /// Ignored if [titleWidget] is provided.
  final String? title;

  /// Optional custom title widget.
  final Widget? titleWidget;

  /// Optional action widgets displayed on the right side of the AppBar.
  final List<Widget>? actions;

  /// Optional bottom widget for the AppBar (e.g., TabBar).
  final PreferredSizeWidget? bottom;

  /// Whether to show the back button. Defaults to true.
  final bool showBackButton;

  /// Whether to center the title. Defaults to true.
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading:
            showBackButton
                ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
                    size: Responsive.w(context, 24),
                  ),
                  onPressed: () => context.go(AppRoutes.home),
                )
                : null,
        automaticallyImplyLeading: showBackButton,
        title:
            titleWidget ??
            (title != null
                ? Text(
                  title!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                )
                : null),
        centerTitle: centerTitle,
        actions: actions,
        bottom: bottom,
      ),
      body: body,
    );
  }
}
