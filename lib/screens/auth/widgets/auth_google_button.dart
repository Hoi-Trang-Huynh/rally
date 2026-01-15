import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/scale_button.dart';

/// An outlined button for Google sign-in used in auth screens.
///
/// Includes bounce animation and haptic feedback.
class AuthGoogleButton extends StatefulWidget {
  /// Creates a new [AuthGoogleButton].
  const AuthGoogleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  /// The button text.
  final String text;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in loading state (disables it).
  final bool isLoading;

  @override
  State<AuthGoogleButton> createState() => _AuthGoogleButtonState();
}

class _AuthGoogleButtonState extends State<AuthGoogleButton> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double buttonHeight = Responsive.h(context, 48);
    final double iconSize = Responsive.w(context, 24);

    if (widget.isLoading) {
      return SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: null,
          child: SizedBox(
            height: iconSize,
            width: iconSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return ScaleButton(
      onTap: widget.onPressed,
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: null, // Let ScaleButton handle taps
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outline),
            disabledForegroundColor: colorScheme.onSurface, // Keep text valid
          ).copyWith(
            side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
              return BorderSide(color: colorScheme.outline);
            }),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/google_logo.png',
                height: iconSize,
                width: iconSize,
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stackTrace) =>
                        Icon(Icons.g_mobiledata, size: Responsive.w(context, 28)),
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Text(widget.text),
            ],
          ),
        ),
      ),
    );
  }
}
