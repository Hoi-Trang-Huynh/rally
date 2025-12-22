import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/screens/auth/login_screen.dart';
import 'package:rally/screens/playground/auth_test.dart';
import 'package:rally/utils/auth_helpers.dart';
import 'package:rally/utils/ui_helpers.dart';
import 'package:rally/utils/validators.dart';
import 'package:rally/widgets/auth_google_button.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';
import 'package:rally/widgets/layout/auth_screen_layout.dart';
import 'package:rally/widgets/or_divider.dart';
import 'package:rally/widgets/password_requirements.dart';
import 'package:rally/widgets/profile_fields_form.dart';

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
  String? _savedUserId;

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

  /// TODO: check if email exists.
  Future<bool> _checkEmailExists(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return false;
  }

  // --- Step Handlers ---

  Future<void> _onContinueStep1() async {
    _clearErrors();

    _emailError = Validators.validateEmail(_emailController.text);
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
    _clearErrors();

    _usernameError = Validators.validateUsername(_usernameController.text);
    _firstNameError = Validators.validateFirstName(_firstNameController.text);
    _lastNameError = Validators.validateLastName(_lastNameController.text);

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
    _clearErrors();

    _passwordError = Validators.validatePassword(_passwordController.text);
    _confirmPasswordError = Validators.validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
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
      // Step 1: Create Firebase user
      await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      // Step 2: Get Firebase ID token
      final String? idToken = await ref.read(authRepositoryProvider).getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Step 3: Register user in backend with Firebase ID token
      final Map<String, dynamic> registerResponse = await ref
          .read(userRepositoryProvider)
          .register(idToken: idToken);

      // Step 4: Extract user ID from register response
      final Map<String, dynamic>? user = registerResponse['user'] as Map<String, dynamic>?;
      final String? userId = user?['id'] as String?;
      _savedUserId = userId;

      if (userId != null) {
        // Step 5: Force refresh the token to ensure it's valid for the next request
        await ref.read(authRepositoryProvider).getIdToken(forceRefresh: true);

        // Step 6: Update user profile with provided information
        await ref
            .read(userRepositoryProvider)
            .updateUserProfile(
              userId: userId,
              username: _savedUsername,
              firstName: _savedFirstName,
              lastName: _savedLastName,
            );

        // Step 7: Invalidate the auth provider to fetch the newly created profile
        ref.invalidate(appUserProvider);
      }

      // Step 6: Send email verification
      await ref.read(authRepositoryProvider).sendEmailVerification();

      if (mounted) {
        setState(() {
          _currentStep = SignupStep.emailVerification;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (mounted) {
        showSuccessSnackBar(context, t.auth.signup.emailResent);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isLoading = true);

    try {
      final bool isVerified = await ref.read(authRepositoryProvider).isEmailVerified();

      if (isVerified && mounted) {
        // Update email verification status in backend
        if (_savedUserId != null) {
          await ref
              .read(userRepositoryProvider)
              .updateUserProfile(userId: _savedUserId!, isEmailVerified: true);
        }

        if (!mounted) return;

        // Invalidate the auth provider to refresh the user state
        // This ensures main.dart sees the updated emailVerified status
        ref.invalidate(appUserProvider);

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const AuthTestScreen()));
      } else if (mounted) {
        showErrorSnackBar(context, t.auth.signup.emailNotVerified);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    await handleGoogleSignInWithNavigation(
      ref: ref,
      context: context,
      onLoadingChanged: (bool isLoading) {
        if (mounted) setState(() => _isLoading = isLoading);
      },
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
    // Watch for locale changes and get the correct translations
    final Translations t = Translations.of(context);

    // Explicitly watch locale provider to ensure rebuilds (belt and suspenders)
    ref.watch(localeProvider);

    return AuthScreenLayout(
      showLogo: _currentStep != SignupStep.emailVerification,
      title: _currentStep != SignupStep.emailVerification ? t.auth.login.createTripHeadline : null,
      bottomText: t.auth.login.alreadyHaveAccountQuestion,
      bottomButtonText: t.auth.login.alreadyHaveAccountAction,
      onBottomButtonPressed: _navigateToLogin,
      child: Column(children: _buildCurrentStep(context)),
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

  // Helper method moved/removed during refactor if unused, but we keep the logic intact
  // Note: logic for showing logo/title is now in AuthScreenLayout params.

  List<Widget> _buildEmailStep(BuildContext context) {
    final Translations t = Translations.of(context);
    return <Widget>[
      AuthTextField(
        controller: _emailController,
        labelText: t.auth.login.emailAddress,
        errorText: _emailError,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: t.common.continueButton,
        onPressed: _onContinueStep1,
        isLoading: _isLoading,
      ),
      const SizedBox(height: 24),
      const OrDivider(),
      const SizedBox(height: 24),
      AuthGoogleButton(
        text: t.auth.login.google,
        onPressed: _signInWithGoogle,
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildProfileStep(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return <Widget>[
      _buildBackButton(_emailController.text, colorScheme),
      const SizedBox(height: 16),
      ProfileFieldsForm(
        usernameController: _usernameController,
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        usernameError: _usernameError,
        firstNameError: _firstNameError,
        lastNameError: _lastNameError,
        isLoading: _isLoading,
        onContinue: _onContinueStep2,
      ),
    ];
  }

  List<Widget> _buildPasswordStep(BuildContext context) {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return <Widget>[
      _buildBackButton(t.auth.signup.stepProfile, colorScheme),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _passwordController,
        labelText: t.auth.login.password,
        errorText: _passwordError,
        obscureText: true,
        onChanged: (String value) => setState(() => _currentPassword = value),
      ),
      const SizedBox(height: 8),
      PasswordRequirements(password: _currentPassword),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _confirmPasswordController,
        labelText: t.auth.signup.confirmPassword,
        errorText: _confirmPasswordError,
        obscureText: true,
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: t.common.continueButton,
        onPressed: _onContinueStep3,
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildEmailVerificationStep(BuildContext context) {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return <Widget>[
      Icon(Icons.mark_email_read_outlined, size: 80, color: colorScheme.primary),
      const SizedBox(height: 24),
      Text(
        t.auth.signup.verifyEmail,
        style: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        t.auth.signup.verifyEmailSubtitle(email: _emailController.text.trim()),
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      AuthPrimaryButton(
        text: t.auth.signup.checkVerification,
        onPressed: _checkEmailVerification,
        isLoading: _isLoading,
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: _isLoading ? null : _resendVerificationEmail,
        child: Text(t.auth.signup.resendEmail, style: TextStyle(color: colorScheme.primary)),
      ),
    ];
  }

  Widget _buildBackButton(String label, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _isLoading ? null : _goBack,
        icon: const Icon(Icons.arrow_back, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
