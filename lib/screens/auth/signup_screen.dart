import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/screens/auth/login_screen.dart';
import 'package:rally/utils/validators.dart';
import 'package:rally/widgets/auth_google_button.dart';
import 'package:rally/widgets/auth_header_row.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';
import 'package:rally/widgets/or_divider.dart';
import 'package:rally/widgets/password_requirements.dart';

/// Signup steps enum for clarity.
enum SignupStep {
  /// Step 1: Email entry
  email,

  /// Step 2: Profile info (username, first name, last name)
  profile,

  /// Step 3: Password creation
  password,

  /// Step 4: Email verification
  emailVerification,
}

/// Screen for user registration (Sign Up).
///
/// This is a four-step signup flow:
/// 1. Email entry and validation
/// 2. Username, first name, last name
/// 3. Password and confirm password
/// 4. Email verification
class SignupScreen extends ConsumerStatefulWidget {
  /// Creates a new [SignupScreen].
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // State
  SignupStep _currentStep = SignupStep.email;
  bool _isLoading = false;
  String _currentPassword = '';

  // Field-specific error messages
  String? _emailError;
  String? _usernameError;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Saved user data (for future use)
  String? _savedUsername;
  String? _savedFirstName;
  String? _savedLastName;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    _emailError = null;
    _usernameError = null;
    _firstNameError = null;
    _lastNameError = null;
    _passwordError = null;
    _confirmPasswordError = null;
  }

  /// Placeholder: check if email exists.
  Future<bool> _checkEmailExists(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return false;
  }

  // --- Step Handlers ---

  Future<void> _onContinueStep1() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    _clearErrors();

    _emailError = Validators.validateEmail(_emailController.text, l10n);
    setState(() {});

    if (_emailError != null) return;

    setState(() => _isLoading = true);

    try {
      final bool exists = await _checkEmailExists(_emailController.text.trim());
      if (exists) {
        setState(() {
          _emailError = 'An account with this email already exists';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentStep = SignupStep.profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _emailError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onContinueStep2() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    _clearErrors();

    _usernameError = Validators.validateUsername(_usernameController.text, l10n);
    _firstNameError = Validators.validateFirstName(_firstNameController.text, l10n);
    _lastNameError = Validators.validateLastName(_lastNameController.text, l10n);

    setState(() {});

    if (_usernameError != null || _firstNameError != null || _lastNameError != null) {
      return;
    }

    _savedUsername = _usernameController.text.trim();
    _savedFirstName = _firstNameController.text.trim();
    _savedLastName = _lastNameController.text.trim();

    setState(() => _currentStep = SignupStep.password);
  }

  Future<void> _onContinueStep3() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    _clearErrors();

    _passwordError = Validators.validatePassword(_passwordController.text, l10n);
    _confirmPasswordError = Validators.validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
      l10n,
    );

    setState(() {});

    if (_passwordError != null || _confirmPasswordError != null) {
      return;
    }

    await _signUp();
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      await ref.read(authRepositoryProvider).sendEmailVerification();

      // ignore: avoid_print
      print(
        'Saved: username=$_savedUsername, firstName=$_savedFirstName, lastName=$_savedLastName',
      );

      if (mounted) {
        setState(() {
          _currentStep = SignupStep.emailVerification;
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.signupEmailResent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isLoading = true);

    try {
      final bool isVerified = await ref.read(authRepositoryProvider).isEmailVerified();
      if (isVerified && mounted) {
        Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
      } else if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.signupEmailNotVerified);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await ref.read(authRepositoryProvider).signInWithCredential(credential);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  void _navigateToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  void _goBack() {
    setState(() {
      _clearErrors();
      switch (_currentStep) {
        case SignupStep.email:
          break;
        case SignupStep.profile:
          _currentStep = SignupStep.email;
        case SignupStep.password:
          _currentStep = SignupStep.profile;
        case SignupStep.emailVerification:
          break; // Cannot go back
      }
    });
  }

  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const AuthHeaderRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 60),
                    if (_currentStep != SignupStep.emailVerification) ...<Widget>[
                      Image.asset('assets/images/rally_logo_transparent.png', height: 100),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 80,
                        child: Text(
                          AppLocalizations.of(context)!.loginCreateTripHeadline,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                    ..._buildCurrentStep(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  AppLocalizations.of(context)!.loginAlreadyHaveAccount,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case SignupStep.email:
        return _buildEmailStep(context);
      case SignupStep.profile:
        return _buildProfileStep(context);
      case SignupStep.password:
        return _buildPasswordStep(context);
      case SignupStep.emailVerification:
        return _buildEmailVerificationStep(context);
    }
  }

  List<Widget> _buildEmailStep(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return <Widget>[
      AuthTextField(
        controller: _emailController,
        labelText: l10n.loginEmailAddress,
        errorText: _emailError,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: l10n.loginContinue,
        onPressed: _onContinueStep1,
        isLoading: _isLoading,
      ),
      const SizedBox(height: 24),
      const OrDivider(),
      const SizedBox(height: 24),
      AuthGoogleButton(text: l10n.loginGoogle, onPressed: _signInWithGoogle, isLoading: _isLoading),
    ];
  }

  List<Widget> _buildProfileStep(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return <Widget>[
      _buildBackButton(_emailController.text, colorScheme),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _usernameController,
        labelText: l10n.signupUsername,
        errorText: _usernameError,
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: AuthTextField(
              controller: _firstNameController,
              labelText: l10n.signupFirstName,
              errorText: _firstNameError,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AuthTextField(
              controller: _lastNameController,
              labelText: l10n.signupLastName,
              errorText: _lastNameError,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: l10n.loginContinue,
        onPressed: _onContinueStep2,
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildPasswordStep(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return <Widget>[
      _buildBackButton(l10n.signupStepProfile, colorScheme),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _passwordController,
        labelText: l10n.loginPassword,
        errorText: _passwordError,
        obscureText: true,
        onChanged: (String value) => setState(() => _currentPassword = value),
      ),
      const SizedBox(height: 8),
      PasswordRequirements(password: _currentPassword),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _confirmPasswordController,
        labelText: l10n.signupConfirmPassword,
        errorText: _confirmPasswordError,
        obscureText: true,
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: l10n.loginContinue,
        onPressed: _onContinueStep3,
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildEmailVerificationStep(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return <Widget>[
      Icon(Icons.mark_email_read_outlined, size: 80, color: colorScheme.primary),
      const SizedBox(height: 24),
      Text(
        l10n.signupVerifyEmail,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        l10n.signupVerifyEmailSubtitle(_emailController.text.trim()),
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      AuthPrimaryButton(
        text: l10n.signupCheckVerification,
        onPressed: _checkEmailVerification,
        isLoading: _isLoading,
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: _isLoading ? null : _resendVerificationEmail,
        child: Text(l10n.signupResendEmail, style: TextStyle(color: colorScheme.primary)),
      ),
    ];
  }

  Widget _buildBackButton(String label, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _goBack,
        icon: const Icon(Icons.arrow_back, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
