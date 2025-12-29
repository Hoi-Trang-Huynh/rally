import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/screens/auth/login_screen.dart';
import 'package:rally/screens/auth/signup_screen.dart';
import 'package:rally/widgets/auth_header_row.dart';

/// A wrapper screen that holds the static header and switches between Login and Signup forms.
///
/// This ensures the Top Bar (Language/Theme) and Logo remain completely static
/// while the form content animates during transitions.
class AuthScreen extends StatefulWidget {
  /// Whether to start in Login mode. Defaults to `true`.
  /// Set to `false` to start in Signup mode.
  final bool initialIsLogin;

  /// Creates a new [AuthScreen].
  const AuthScreen({super.key, this.initialIsLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  void _toggleAuthMode() {
    // Haptic feedback when switching modes
    HapticFeedback.lightImpact();
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // 1. Static Top Bar
            const AuthHeaderRow(),

            // 2. Static Content (Logo & Title) + Animated Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/rally_logo_transparent.png',
                        height: isSmallScreen ? 70 : 100,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Animated Switcher for Form Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child:
                          _isLogin
                              ? _LoginFormWrapper(
                                key: const ValueKey<String>('Login'),
                                onRegisterClicked: _toggleAuthMode,
                              )
                              : _SignupFormWrapper(
                                key: const ValueKey<String>('Signup'),
                                onLoginClicked: _toggleAuthMode,
                              ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Static Bottom Link (Footer)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: TextButton(
                onPressed: _toggleAuthMode,
                child: Text.rich(
                  TextSpan(
                    text:
                        _isLogin
                            ? '${t.auth.login.needAccountQuestion} '
                            : '${t.auth.login.alreadyHaveAccountQuestion} ',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    children: <InlineSpan>[
                      TextSpan(
                        text:
                            _isLogin
                                ? t.auth.login.needAccountAction
                                : t.auth.login.alreadyHaveAccountAction,
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

class _LoginFormWrapper extends StatelessWidget {
  final VoidCallback onRegisterClicked;
  const _LoginFormWrapper({super.key, required this.onRegisterClicked});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(onRegisterClicked: onRegisterClicked);
  }
}

class _SignupFormWrapper extends StatelessWidget {
  final VoidCallback onLoginClicked;
  const _SignupFormWrapper({super.key, required this.onLoginClicked});

  @override
  Widget build(BuildContext context) {
    return SignupScreen(onLoginClicked: onLoginClicked);
  }
}
