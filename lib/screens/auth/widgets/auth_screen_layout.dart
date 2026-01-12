import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/screens/auth/widgets/auth_header_row.dart';
import 'package:rally/utils/responsive.dart';

/// A shared layout widget for authentication screens (Login and Signup).
///
/// This widget provides a consistent structure with a header, scrollable content area,
/// and an optional bottom action button (e.g., "Don't have an account? Sign up").
/// It handles responsiveness for smaller screens by adjusting padding and sizing.
///
/// Includes Staggered Animations for content (provided by child) and Hero transition for logo.
class AuthScreenLayout extends StatelessWidget {
  /// The main content of the screen (form fields, buttons, etc.).
  final Widget child;

  /// Optional title displayed at the top of the content area.
  final String? title;

  /// Optional subtitle displayed below the title.
  final String? subtitle;

  /// The text for the question part of the bottom link (e.g., "Need an account?").
  final String? bottomText;

  /// The text for the action part of the bottom link (e.g., "Join now").
  /// This text is styled to look clickable.
  final String? bottomButtonText;

  /// Callback executed when the bottom link is pressed.
  final VoidCallback? onBottomButtonPressed;

  /// Whether to display the app logo at the top. Defaults to `true`.
  final bool showLogo;

  /// Creates an [AuthScreenLayout].
  const AuthScreenLayout({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.bottomText,
    this.bottomButtonText,
    this.onBottomButtonPressed,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Static Top Bar (Language/Theme)
            const AuthHeaderRow(),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Static Header Elements (Logo, Title, Subtitle)
                    // These do NOT slide in on every screen switch
                    if (showLogo) ...<Widget>[
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/images/rally_logo_transparent.png',
                          height: Responsive.h(context, 100),
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 24)),
                    ],
                    if (title != null) ...<Widget>[
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 48)),
                    ],
                    if (subtitle != null) ...<Widget>[
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Responsive.h(context, 48)),
                    ],

                    // Animated Form Content
                    // Wrapped in AnimationLimiter so the staggered list inside 'child' functions correctly
                    AnimationLimiter(child: child),
                  ],
                ),
              ),
            ),

            if (bottomText != null && bottomButtonText != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 24),
                  vertical: Responsive.h(context, 16),
                ),
                child: TextButton(
                  onPressed: () {
                    if (onBottomButtonPressed != null) {
                      HapticFeedback.lightImpact();
                      onBottomButtonPressed!();
                    }
                  },
                  child: Text.rich(
                    TextSpan(
                      text: '$bottomText ',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      children: <InlineSpan>[
                        TextSpan(
                          text: bottomButtonText,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
