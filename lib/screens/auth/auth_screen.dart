import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/screens/auth/login_screen.dart';
import 'package:rally/screens/auth/signup_screen.dart';
import 'package:rally/screens/auth/widgets/auth_header_row.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/animated_background.dart';
import 'package:rally/widgets/common/glass_container.dart';

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
  bool _hideLogoForVerification = false;

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
      _hideLogoForVerification = false;
    });
  }

  void _onVerificationStepChanged(bool isVerifying) {
    setState(() {
      _hideLogoForVerification = isVerifying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;
    final bool isVerySmallScreen = screenHeight < 650;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          // 0. Dynamic Background
          const AnimatedBackground(),

          SafeArea(
            child: Column(
              children: <Widget>[
                // 1. Static Top Bar
                const AuthHeaderRow(),

                // 2. Center Content with Glass Effect
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Only show logo if not in verification step
                          if (!_hideLogoForVerification) ...<Widget>[
                            Hero(
                              tag: 'app_logo',
                              child: Image.asset(
                                'assets/images/rally_logo_transparent.png',
                                height:
                                    isVerySmallScreen
                                        ? Responsive.h(context, 50)
                                        : isSmallScreen
                                        ? Responsive.h(context, 65)
                                        : Responsive.h(context, 90),
                              ),
                            ),
                            SizedBox(
                              height:
                                  isVerySmallScreen
                                      ? Responsive.h(context, 8)
                                      : isSmallScreen
                                      ? Responsive.h(context, 12)
                                      : Responsive.h(context, 24),
                            ),
                          ],

                          // Glass Container for Form
                          GlassContainer(
                            // Lower opacity in Light mode to blend better, higher in Dark for contrast
                            opacity: Theme.of(context).brightness == Brightness.light ? 0.3 : 0.6,
                            shadows: <BoxShadow>[
                              BoxShadow(
                                color: colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: Responsive.w(context, 24),
                                offset: Offset(0, Responsive.h(context, 8)),
                              ),
                            ],
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutBack,
                              child: Padding(
                                padding: EdgeInsets.all(
                                  isVerySmallScreen
                                      ? Responsive.w(context, 16)
                                      : Responsive.w(context, 20),
                                ),
                                child: AnimatedSwitcher(
                                  layoutBuilder: (
                                    Widget? currentChild,
                                    List<Widget> previousChildren,
                                  ) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        ...previousChildren,
                                        if (currentChild != null) currentChild,
                                      ],
                                    );
                                  },
                                  duration: const Duration(milliseconds: 500),
                                  switchInCurve: Curves.easeOutBack,
                                  switchOutCurve: Curves.easeInBack,
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    final bool isEntering =
                                        child.key ==
                                        ValueKey<String>(_isLogin ? 'Login' : 'Signup');

                                    // Slide direction depends on mode (Login <-> Signup)
                                    final Offset beginOffset =
                                        isEntering
                                            ? (_isLogin
                                                ? const Offset(-0.1, 0)
                                                : const Offset(0.1, 0))
                                            : (_isLogin
                                                ? const Offset(0.1, 0)
                                                : const Offset(-0.1, 0));

                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: beginOffset,
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
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
                                            onVerificationStepChanged: _onVerificationStepChanged,
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Static Bottom Link (Footer) - hide during verification
                if (!_hideLogoForVerification)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                      vertical: Responsive.h(context, 12),
                    ),
                    child: TextButton(
                      onPressed: _toggleAuthMode,
                      child: Text.rich(
                        TextSpan(
                          text:
                              _isLogin
                                  ? '${t.auth.login.needAccountQuestion} '
                                  : '${t.auth.login.alreadyHaveAccountQuestion} ',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text:
                                  _isLogin
                                      ? t.auth.login.needAccountAction
                                      : t.auth.login.alreadyHaveAccountAction,
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: colorScheme.primary.withValues(alpha: 0.5),
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
        ],
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
  final ValueChanged<bool> onVerificationStepChanged;
  const _SignupFormWrapper({
    super.key,
    required this.onLoginClicked,
    required this.onVerificationStepChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SignupScreen(
      onLoginClicked: onLoginClicked,
      onVerificationStepChanged: onVerificationStepChanged,
    );
  }
}
