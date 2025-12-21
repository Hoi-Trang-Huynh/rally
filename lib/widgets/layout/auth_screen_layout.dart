import 'package:flutter/material.dart';
import 'package:rally/widgets/auth_header_row.dart';

class AuthScreenLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final String? bottomText;
  final String? bottomButtonText;
  final VoidCallback? onBottomButtonPressed;
  final bool showLogo;

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
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AuthHeaderRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (showLogo) ...<Widget>[
                      Image.asset(
                        'assets/images/rally_logo_transparent.png',
                        height: isSmallScreen ? 70 : 100,
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                    ],
                    if (title != null) ...<Widget>[
                      Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: isSmallScreen ? 22 : null,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 24 : 40),
                    ],
                    if (subtitle != null) ...<Widget>[
                      Text(
                        subtitle!,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],
                    child,
                  ],
                ),
              ),
            ),
            if (bottomText != null && bottomButtonText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: TextButton(
                  onPressed: onBottomButtonPressed,
                  child: Text.rich(
                    TextSpan(
                      text: '$bottomText ',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                      children: <InlineSpan>[
                        TextSpan(
                          text: bottomButtonText,
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
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
