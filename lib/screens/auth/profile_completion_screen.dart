import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/utils/ui_helpers.dart';
import 'package:rally/utils/validators.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';
import 'package:rally/widgets/layout/auth_screen_layout.dart';

/// Screen for completing user profile after Google Sign-In.
///
/// This screen is shown when a user signs in with Google but hasn't
/// filled in their username, firstName, or lastName yet.
class ProfileCompletionScreen extends ConsumerStatefulWidget {
  /// Creates a new [ProfileCompletionScreen].
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends ConsumerState<ProfileCompletionScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;
  String? _usernameError;
  String? _firstNameError;
  String? _lastNameError;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    // Clear errors
    setState(() {
      _usernameError = null;
      _firstNameError = null;
      _lastNameError = null;
    });

    // Validate
    _usernameError = Validators.validateUsername(_usernameController.text);
    _firstNameError = Validators.validateFirstName(_firstNameController.text);
    _lastNameError = Validators.validateLastName(_lastNameController.text);

    setState(() {});

    if (_usernameError != null || _firstNameError != null || _lastNameError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if username is available
      final bool available = await ref
          .read(userRepositoryProvider)
          .checkUsernameAvailability(_usernameController.text.trim());
      if (!available) {
        setState(() {
          _usernameError = t.validation.username.taken;
          _isLoading = false;
        });
        return;
      }

      // Get current user ID
      final AppUser? user = ref.read(appUserProvider).valueOrNull;
      if (user?.id == null) {
        throw Exception('User ID not found');
      }

      // Update profile
      await ref
          .read(userRepositoryProvider)
          .updateUserProfile(
            userId: user!.id!,
            username: _usernameController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );

      // Refresh auth state to trigger main.dart routing
      ref.invalidate(appUserProvider);
    } catch (e) {
      if (mounted) showErrorSnackBar(context, e.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale provider to rebuild when locale changes
    ref.watch(localeProvider);

    return AuthScreenLayout(
      title: t.auth.signup.completeProfile,
      child: Column(
        children: <Widget>[
          AuthTextField(
            controller: _usernameController,
            labelText: t.auth.signup.username,
            errorText: _usernameError,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AuthTextField(
                  controller: _firstNameController,
                  labelText: t.auth.signup.firstName,
                  errorText: _firstNameError,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AuthTextField(
                  controller: _lastNameController,
                  labelText: t.auth.signup.lastName,
                  errorText: _lastNameError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            text: t.common.continueButton,
            onPressed: _onSubmit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
