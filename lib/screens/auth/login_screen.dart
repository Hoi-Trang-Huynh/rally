import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/screens/auth/widgets/auth_google_button.dart';
import 'package:rally/screens/auth/widgets/auth_primary_button.dart';
import 'package:rally/screens/auth/widgets/auth_text_field.dart';
import 'package:rally/screens/auth/widgets/or_divider.dart';
import 'package:rally/utils/auth_helpers.dart';
import 'package:rally/utils/responsive.dart';

/// Form content for Login.
///
/// Designed to be embedded in [AuthScreen].
class LoginScreen extends ConsumerStatefulWidget {
  /// Callback to switch to registration mode.
  final VoidCallback onRegisterClicked;

  /// Creates a new [LoginScreen].
  const LoginScreen({super.key, required this.onRegisterClicked});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isSignInLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _errorMessage = null;
      _isSignInLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      // Navigation to home is handled by main.dart listener on auth state
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSignInLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _errorMessage = null);
    await handleGoogleSignInWithNavigation(
      ref: ref,
      context: context,
      onLoadingChanged: (bool isLoading) {
        if (mounted) setState(() => _isGoogleLoading = isLoading);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for locale changes and get the correct translations
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool anyLoading = _isSignInLoading || _isGoogleLoading;

    return Column(
      children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 375),
        childAnimationBuilder: (Widget widget) {
          return SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget));
        },
        children: <Widget>[
          // Title (Moved here from Layout so it Animates)
          Text(
            t.auth.login.welcomeBack,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: Responsive.h(context, 24)),

          // Error Message
          if (_errorMessage != null) ...<Widget>[
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(context, 12)),
          ],

          // Email Field
          AuthTextField(
            controller: _emailController,
            labelText: t.auth.login.emailAddress,
            keyboardType: TextInputType.emailAddress,
            enabled: !anyLoading,
          ),
          SizedBox(height: Responsive.h(context, 12)),

          // Password Field
          AuthTextField(
            controller: _passwordController,
            labelText: t.auth.login.password,
            obscureText: true,
            enabled: !anyLoading,
          ),
          SizedBox(height: Responsive.h(context, 16)),

          AuthPrimaryButton(
            text: t.common.continueButton,
            onPressed: anyLoading ? null : _signIn,
            isLoading: _isSignInLoading,
          ),
          SizedBox(height: Responsive.h(context, 16)),

          const OrDivider(),
          SizedBox(height: Responsive.h(context, 16)),

          // Google Button
          AuthGoogleButton(
            text: t.auth.login.google,
            onPressed: anyLoading ? null : _signInWithGoogle,
            isLoading: _isGoogleLoading,
          ),
        ],
      ),
    );
  }
}
