import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/scale_button.dart';

/// Style variants for [AuthFilledButton].
enum AuthButtonStyle {
  /// Primary filled style with solid background color.
  primary,

  /// Secondary outlined style with border.
  outlined,
}

/// A versatile filled button used in auth screens.
///
/// Supports both primary (filled) and outlined (secondary) styles with
/// consistent shape and sizing. Shows a loading indicator when [isLoading] is true.
/// Includes bounce animation and haptic feedback.
class AuthFilledButton extends StatelessWidget {
  /// Creates a new [AuthFilledButton].
  const AuthFilledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = AuthButtonStyle.primary,
    this.icon,
    this.isLoading = false,
  });

  /// The button text.
  final String text;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// The visual style of the button.
  final AuthButtonStyle style;

  /// Optional leading icon widget (e.g., Google logo).
  final Widget? icon;

  /// Whether to show loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double buttonHeight = Responsive.h(context, 48);
    final double spinnerSize = Responsive.w(context, 24);
    final double borderRadius = Responsive.w(context, 12);

    // Build the content (icon + text or just text)
    Widget content;
    if (icon != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[icon!, SizedBox(width: Responsive.w(context, 8)), Text(text)],
      );
    } else {
      content = Text(text);
    }

    // Loading state
    if (isLoading) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: _buildButtonContainer(
          context: context,
          borderRadius: borderRadius,
          child: Center(
            child: SizedBox(
              height: spinnerSize,
              width: spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    style == AuthButtonStyle.primary
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ),
      );
    }

    // Normal state with ScaleButton animation
    return ScaleButton(
      onTap: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: _buildButtonContainer(context: context, borderRadius: borderRadius, child: content),
      ),
    );
  }

  Widget _buildButtonContainer({
    required BuildContext context,
    required double borderRadius,
    required Widget child,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle textStyle = Theme.of(context).textTheme.labelLarge ?? const TextStyle();

    switch (style) {
      case AuthButtonStyle.primary:
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: textStyle.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
            child: child,
          ),
        );

      case AuthButtonStyle.outlined:
        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: colorScheme.outline),
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: textStyle.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            child: child,
          ),
        );
    }
  }
}
