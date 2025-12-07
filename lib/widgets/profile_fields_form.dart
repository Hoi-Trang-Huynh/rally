import 'package:flutter/material.dart';
import 'package:rally/l10n/generated/app_localizations.dart';
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
    this.onBack,
    this.backLabel,
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

  /// Optional callback for the back button.
  final VoidCallback? onBack;

  /// Optional label for the back button.
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (onBack != null && backLabel != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(backLabel!),
              style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
            ),
          ),
        if (onBack != null) const SizedBox(height: 16),
        AuthTextField(
          controller: usernameController,
          labelText: l10n.signupUsername,
          errorText: usernameError,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: AuthTextField(
                controller: firstNameController,
                labelText: l10n.signupFirstName,
                errorText: firstNameError,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthTextField(
                controller: lastNameController,
                labelText: l10n.signupLastName,
                errorText: lastNameError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(text: l10n.loginContinue, onPressed: onContinue, isLoading: isLoading),
      ],
    );
  }
}
