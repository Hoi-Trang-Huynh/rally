import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/widgets/auth_primary_button.dart';
import 'package:rally/widgets/auth_text_field.dart';

/// A reusable form widget for collecting user profile fields.
///
/// Contains username, firstName, and lastName text fields with validation
/// error display and a continue button.
class ProfileFieldsForm extends StatelessWidget {
  /// Creates a new [ProfileFieldsForm].
  const ProfileFieldsForm({
    required this.usernameController,
    required this.firstNameController,
    required this.lastNameController,
    required this.onContinue,
    this.usernameError,
    this.firstNameError,
    this.lastNameError,
    this.isLoading = false,
    super.key,
  });

  /// Controller for the username field.
  final TextEditingController usernameController;

  /// Controller for the first name field.
  final TextEditingController firstNameController;

  /// Controller for the last name field.
  final TextEditingController lastNameController;

  /// Callback when the continue button is pressed.
  final VoidCallback onContinue;

  /// Error message for the username field.
  final String? usernameError;

  /// Error message for the first name field.
  final String? firstNameError;

  /// Error message for the last name field.
  final String? lastNameError;

  /// Whether the form is in a loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthTextField(
          controller: usernameController,
          labelText: t.auth.signup.username,
          errorText: usernameError,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: AuthTextField(
                controller: firstNameController,
                labelText: t.auth.signup.firstName,
                errorText: firstNameError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthTextField(
                controller: lastNameController,
                labelText: t.auth.signup.lastName,
                errorText: lastNameError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          text: t.common.continueButton,
          onPressed: onContinue,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
