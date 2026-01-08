import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/screens/playground/auth_test.dart';
import 'package:rally/utils/auth_helpers.dart';
import 'package:rally/utils/ui_helpers.dart';
import 'package:rally/utils/validators.dart';
import 'package:rally/widgets/auth_google_button.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';
import 'package:rally/widgets/or_divider.dart';
import 'package:rally/widgets/password_requirements.dart';
import 'package:rally/widgets/profile_fields_form.dart';

/// Signup steps enum for clarity.
enum SignupStep {
  /// Step 1: Email entry
  email,

  /// Step 2: Profile info
  profile,

  /// Step 3: Password creation
  password,

  /// Step 4: Email verification
  emailVerification,
}

/// Form content for Signup.
///
/// Designed to be embedded in [AuthScreen].
class SignupScreen extends ConsumerStatefulWidget {
  /// Callback to switch to login mode.
  final VoidCallback onLoginClicked;

  /// Callback when entering/exiting the email verification step.
  final ValueChanged<bool>? onVerificationStepChanged;

  /// Creates a new [SignupScreen].
  const SignupScreen({super.key, required this.onLoginClicked, this.onVerificationStepChanged});

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
  bool _isSignupLoading = false;
  bool _isGoogleLoading = false;
  String _currentPassword = '';

  // Field-specific error messages
  String? _emailError;
  String? _usernameError;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Saved user data
  String? _savedUsername;
  String? _savedFirstName;
  String? _savedLastName;
  String? _savedUserId;

  bool get _anyLoading => _isSignupLoading || _isGoogleLoading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingAuthState();
    });
  }

  Future<void> _checkExistingAuthState() async {
    final AsyncValue<AppUser?> authState = ref.read(appUserProvider);
    authState.whenData((AppUser? user) {
      if (user != null && !user.isEmailVerified && mounted) {
        setState(() {
          _emailController.text = user.email ?? '';
          _currentStep = SignupStep.emailVerification;
        });
        widget.onVerificationStepChanged?.call(true);
      }
    });
  }

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

  Future<bool> _checkEmailExists(String email) async {
    final bool available = await ref.read(userRepositoryProvider).checkEmailAvailability(email);
    return !available; // returns true if email EXISTS (not available)
  }

  Future<bool> _checkUsernameExists(String username) async {
    final bool available = await ref
        .read(userRepositoryProvider)
        .checkUsernameAvailability(username);
    return !available; // returns true if username EXISTS (not available)
  }

  // --- Step Handlers ---
  Future<void> _onContinueStep1() async {
    _clearErrors();
    _emailError = Validators.validateEmail(_emailController.text);
    setState(() {});
    if (_emailError != null) return;

    setState(() => _isSignupLoading = true);
    try {
      final bool exists = await _checkEmailExists(_emailController.text.trim());
      if (exists) {
        setState(() {
          _emailError = t.validation.email.taken;
          _isSignupLoading = false;
        });
        return;
      }
      setState(() {
        _currentStep = SignupStep.profile;
        _isSignupLoading = false;
      });
    } catch (e) {
      setState(() {
        _emailError = e.toString();
        _isSignupLoading = false;
      });
    }
  }

  Future<void> _onContinueStep2() async {
    _clearErrors();
    _usernameError = Validators.validateUsername(_usernameController.text);
    _firstNameError = Validators.validateFirstName(_firstNameController.text);
    _lastNameError = Validators.validateLastName(_lastNameController.text);
    setState(() {});
    if (_usernameError != null || _firstNameError != null || _lastNameError != null) return;

    setState(() => _isSignupLoading = true);
    try {
      final bool exists = await _checkUsernameExists(_usernameController.text.trim());
      if (exists) {
        setState(() {
          _usernameError = t.validation.username.taken;
          _isSignupLoading = false;
        });
        return;
      }
      _savedUsername = _usernameController.text.trim();
      _savedFirstName = _firstNameController.text.trim();
      _savedLastName = _lastNameController.text.trim();
      setState(() {
        _currentStep = SignupStep.password;
        _isSignupLoading = false;
      });
    } catch (e) {
      setState(() {
        _usernameError = e.toString();
        _isSignupLoading = false;
      });
    }
  }

  Future<void> _onContinueStep3() async {
    _clearErrors();
    _passwordError = Validators.validatePassword(_passwordController.text);
    _confirmPasswordError = Validators.validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );
    setState(() {});
    if (_passwordError != null || _confirmPasswordError != null) return;
    await _signUp();
  }

  Future<void> _signUp() async {
    setState(() => _isSignupLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      final String? idToken = await ref.read(authRepositoryProvider).getIdToken();
      if (idToken == null) throw Exception('Failed to get Firebase ID token');

      final Map<String, dynamic> registerResponse = await ref
          .read(userRepositoryProvider)
          .register(idToken: idToken);

      final Map<String, dynamic>? user = registerResponse['user'] as Map<String, dynamic>?;
      final String? userId = user?['id'] as String?;
      _savedUserId = userId;

      if (userId != null) {
        await ref.read(authRepositoryProvider).getIdToken(forceRefresh: true);
        await ref
            .read(userRepositoryProvider)
            .updateUserProfile(
              userId: userId,
              username: _savedUsername,
              firstName: _savedFirstName,
              lastName: _savedLastName,
            );
      }
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (mounted) {
        setState(() {
          _currentStep = SignupStep.emailVerification;
          _isSignupLoading = false;
        });
        widget.onVerificationStepChanged?.call(true);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
      if (mounted) setState(() => _isSignupLoading = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isSignupLoading = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
      if (mounted) showSuccessSnackBar(context, Translations.of(context).auth.signup.emailResent);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isSignupLoading = false);
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isSignupLoading = true);
    try {
      final bool isVerified = await ref.read(authRepositoryProvider).isEmailVerified();
      if (isVerified && mounted) {
        if (_savedUserId != null) {
          await ref
              .read(userRepositoryProvider)
              .updateUserProfile(userId: _savedUserId!, isEmailVerified: true);
        }
        if (!mounted) return;
        ref.invalidate(appUserProvider);
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const AuthTestScreen()));
      } else if (mounted) {
        showErrorSnackBar(context, Translations.of(context).auth.signup.emailNotVerified);
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
    } finally {
      if (mounted) setState(() => _isSignupLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    await handleGoogleSignInWithNavigation(
      ref: ref,
      context: context,
      onLoadingChanged: (bool isLoading) {
        if (mounted) setState(() => _isGoogleLoading = isLoading);
      },
    );
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
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale provider
    ref.watch(localeProvider);
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenHeight < 700;

    return Column(
      children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 375),
        childAnimationBuilder: (Widget widget) {
          return SlideAnimation(verticalOffset: 50.0, child: FadeInAnimation(child: widget));
        },
        children: <Widget>[
          // Title (Only if NOT verifying email)
          if (_currentStep != SignupStep.emailVerification) ...<Widget>[
            Text(
              t.auth.login.createTripHeadline,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontSize: isSmallScreen ? 22 : null,
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 48),
          ],

          // Form Content
          ..._buildCurrentStep(context),
        ],
      ),
    );
  }

  List<Widget> _buildCurrentStep(BuildContext context) {
    if (_currentStep == SignupStep.emailVerification) return _buildEmailVerificationStep(context);
    switch (_currentStep) {
      case SignupStep.email:
        return _buildEmailStep(context);
      case SignupStep.profile:
        return _buildProfileStep(context);
      case SignupStep.password:
        return _buildPasswordStep(context);
      default:
        return <Widget>[];
    }
  }

  List<Widget> _buildEmailStep(BuildContext context) {
    final Translations t = Translations.of(context);
    return <Widget>[
      AuthTextField(
        controller: _emailController,
        labelText: t.auth.login.emailAddress,
        errorText: _emailError,
        keyboardType: TextInputType.emailAddress,
        enabled: !_anyLoading,
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: t.common.continueButton,
        onPressed: _anyLoading ? null : _onContinueStep1,
        isLoading: _isSignupLoading,
      ),
      const SizedBox(height: 24),
      const OrDivider(),
      const SizedBox(height: 24),
      AuthGoogleButton(
        text: t.auth.login.google,
        onPressed: _anyLoading ? null : _signInWithGoogle,
        isLoading: _isGoogleLoading,
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
        isLoading: _isSignupLoading,
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
        enabled: !_anyLoading,
      ),
      const SizedBox(height: 8),
      PasswordRequirements(password: _currentPassword),
      const SizedBox(height: 16),
      AuthTextField(
        controller: _confirmPasswordController,
        labelText: t.auth.signup.confirmPassword,
        errorText: _confirmPasswordError,
        obscureText: true,
        enabled: !_anyLoading,
      ),
      const SizedBox(height: 24),
      AuthPrimaryButton(
        text: t.common.continueButton,
        onPressed: _anyLoading ? null : _onContinueStep3,
        isLoading: _isSignupLoading,
      ),
    ];
  }

  List<Widget> _buildEmailVerificationStep(BuildContext context) {
    final Translations t = Translations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return <Widget>[
      // Back button at the top
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _anyLoading ? null : _cancelVerificationAndGoBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Back'),
          style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
        ),
      ),
      const SizedBox(height: 16),
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
        isLoading: _isSignupLoading,
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: _isSignupLoading ? null : _resendVerificationEmail,
        child: Text(t.auth.signup.resendEmail, style: TextStyle(color: colorScheme.primary)),
      ),
    ];
  }

  Future<void> _cancelVerificationAndGoBack() async {
    // Sign out the unverified user and return to signup
    await ref.read(authRepositoryProvider).signOut();
    widget.onVerificationStepChanged?.call(false);
    setState(() {
      _currentStep = SignupStep.email;
      _clearErrors();
    });
  }

  Widget _buildBackButton(String label, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _anyLoading ? null : _goBack,
        icon: const Icon(Icons.arrow_back, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
