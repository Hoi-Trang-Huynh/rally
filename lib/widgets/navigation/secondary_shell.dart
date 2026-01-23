import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/utils/responsive.dart';

/// A shell wrapper for screens outside the main [MainShell].
///
/// Provides a consistent minimal AppBar with:
/// - Back button (leading)
/// - Optional title
/// - Optional trailing actions
///
/// Use this for standalone screens like user profiles, settings sub-pages, etc.
/// that don't show the main bottom navbar.
class SecondaryShell extends StatelessWidget {
  /// Creates a [SecondaryShell].
  const SecondaryShell({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.onBack,
  });

  /// The main content of the screen.
  final Widget body;

  /// Optional title displayed in the AppBar.
  final String? title;

  /// Optional action widgets displayed on the right side of the AppBar.
  final List<Widget>? actions;

  /// Whether to show the back button. Defaults to true.
  final bool showBackButton;

  /// Optional custom back navigation callback.
  /// If null, defaults to `context.pop()`.
  final VoidCallback? onBack;

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
                  onPressed: onBack ?? () => context.pop(),
                )
                : null,
        automaticallyImplyLeading: showBackButton,
        title:
            title != null
                ? Text(
                  title!,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                )
                : null,
        centerTitle: true,
        actions: actions,
      ),
      body: body,
    );
  }
}
