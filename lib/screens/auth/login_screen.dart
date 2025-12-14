import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/screens/auth/signup_screen.dart';
import 'package:rally/utils/auth_helpers.dart';
import 'package:rally/widgets/auth_google_button.dart';
import 'package:rally/widgets/auth_header_row.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';
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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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
                    Image.asset(
                      'assets/images/rally_logo_transparent.png',
                      height: isSmallScreen ? 70 : 100,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      l10n.loginWelcomeBack,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: isSmallScreen ? 22 : null,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 40),

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
                      labelText: l10n.loginEmailAddress,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      labelText: l10n.loginPassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Continue Button
                    AuthPrimaryButton(
                      text: l10n.loginContinue,
                      onPressed: _signIn,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),

                    const OrDivider(),
                    const SizedBox(height: 24),

                    // Google Button
                    AuthGoogleButton(
                      text: l10n.loginGoogle,
                      onPressed: _signInWithGoogle,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom panel - Link to Signup
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: TextButton(
                onPressed: _navigateToSignup,
                child: Text(
                  l10n.loginNeedAccount,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
