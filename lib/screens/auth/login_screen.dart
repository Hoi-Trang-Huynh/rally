import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/screens/auth/signup_screen.dart';
import 'package:rally/utils/auth_helpers.dart';
import 'package:rally/widgets/auth_google_button.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';
import 'package:rally/widgets/layout/auth_screen_layout.dart';
import 'package:rally/widgets/or_divider.dart';

/// Screen for user authentication (Login).
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a new [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _errorMessage = null);
    await handleGoogleSignInWithNavigation(
      ref: ref,
      context: context,
      onLoadingChanged: (bool isLoading) {
        if (mounted) setState(() => _isLoading = isLoading);
      },
    );
  }

  void _navigateToSignup() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AuthScreenLayout(
      title: t.auth.login.welcomeBack,
      bottomText: t.auth.login.needAccountQuestion,
      bottomButtonText: t.auth.login.needAccountAction,
      onBottomButtonPressed: _navigateToSignup,
      child: Column(
        children: <Widget>[
          // Error Message
          if (_errorMessage != null) ...<Widget>[
            Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // Email Field
          AuthTextField(
            controller: _emailController,
            labelText: t.auth.login.emailAddress,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password Field
          AuthTextField(
            controller: _passwordController,
            labelText: t.auth.login.password,
            obscureText: true,
          ),
          const SizedBox(height: 24),

          AuthPrimaryButton(
            text: t.common.continueButton,
            onPressed: _signIn,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),

          const OrDivider(),
          const SizedBox(height: 24),

          // Google Button
          AuthGoogleButton(
            text: t.auth.login.google,
            onPressed: _signInWithGoogle,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
