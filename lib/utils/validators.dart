import 'package:rally/l10n/generated/app_localizations.dart';
import 'package:rally/utils/validation_constants.dart';

/// Collection of validation functions for form fields.
///
/// Each function returns `null` if valid, or an error message string if invalid.
class Validators {
  /// Validates an email address.
  /// Returns error message if invalid, null if valid.
  static String? validateEmail(String value, AppLocalizations l10n) {
    final String email = value.trim();

    if (email.isEmpty) {
      return l10n.validationRequired;
    }

    if (!emailRegex.hasMatch(email)) {
      return l10n.validationEmailInvalid;
    }

    return null;
  }

  /// Validates a username.
  /// Returns error message if invalid, null if valid.
  static String? validateUsername(String value, AppLocalizations l10n) {
    final String username = value.trim();

    if (username.isEmpty) {
      return l10n.validationRequired;
    }

    if (username.length < UsernameValidation.minLength) {
      return l10n.validationUsernameTooShort(UsernameValidation.minLength);
    }

    if (username.length > UsernameValidation.maxLength) {
      return l10n.validationUsernameTooLong(UsernameValidation.maxLength);
    }

    return null;
  }

  /// Validates a first name.
  /// Returns error message if invalid, null if valid.
  static String? validateFirstName(String value, AppLocalizations l10n) {
    final String firstName = value.trim();

    if (firstName.isEmpty) {
      return l10n.validationRequired;
    }

    if (firstName.length < FirstNameValidation.minLength) {
      return l10n.validationNameTooShort(FirstNameValidation.minLength);
    }

    if (firstName.length > FirstNameValidation.maxLength) {
      return l10n.validationNameTooLong(FirstNameValidation.maxLength);
    }

    return null;
  }

  /// Validates a last name.
  /// Returns error message if invalid, null if valid.
  static String? validateLastName(String value, AppLocalizations l10n) {
    final String lastName = value.trim();

    if (lastName.isEmpty) {
      return l10n.validationRequired;
    }

    if (lastName.length < LastNameValidation.minLength) {
      return l10n.validationNameTooShort(LastNameValidation.minLength);
    }

    if (lastName.length > LastNameValidation.maxLength) {
      return l10n.validationNameTooLong(LastNameValidation.maxLength);
    }

    return null;
  }

  /// Validates a password.
  /// Returns error message if invalid, null if valid.
  static String? validatePassword(String value, AppLocalizations l10n) {
    final String password = value.trim();

    if (password.isEmpty) {
      return l10n.validationRequired;
    }

    if (!PasswordValidation.isValid(password)) {
      return l10n.validationPasswordTooShort(PasswordValidation.minLength);
    }

    return null;
  }

  /// Validates confirm password matches password.
  /// Returns error message if invalid, null if valid.
  static String? validateConfirmPassword(
    String confirmPassword,
    String password,
    AppLocalizations l10n,
  ) {
    final String trimmedConfirm = confirmPassword.trim();
    final String trimmedPassword = password.trim();

    if (trimmedConfirm.isEmpty) {
      return l10n.validationRequired;
    }

    if (trimmedConfirm != trimmedPassword) {
      return l10n.validationPasswordsDoNotMatch;
    }

    return null;
  }
}
