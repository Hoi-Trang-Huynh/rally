import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/scale_button.dart';

/// A primary filled button used in auth screens.
///
/// Shows a loading indicator when [isLoading] is true.
/// Includes bounce animation and haptic feedback.
class AuthPrimaryButton extends StatefulWidget {
  /// Creates a new [AuthPrimaryButton].
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  /// The button text.
  final String text;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether to show loading indicator.
  final bool isLoading;

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    final double buttonHeight = Responsive.h(context, 44);
    final double spinnerSize = Responsive.w(context, 24);

    if (widget.isLoading) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: FilledButton(
          onPressed: null,
          child: SizedBox(
            height: spinnerSize,
            width: spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
      );
    }

    return ScaleButton(
      onTap: widget.onPressed,
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: FilledButton(
          // We disable the button's internal tap to let ScaleButton handle it,
          // but we keep the visual style.
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            disabledBackgroundColor: Theme.of(context).colorScheme.primary,
            disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
