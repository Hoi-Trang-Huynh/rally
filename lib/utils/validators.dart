import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/utils/validation_constants.dart';

/// Collection of validation functions for form fields.
///
/// Each function returns `null` if valid, or an error message string if invalid.
class Validators {
  /// Validates an email address.
  /// Returns error message if invalid, null if valid.
  static String? validateEmail(String value) {
    final String email = value.trim();

    if (email.isEmpty) {
      return t.validation.required;
    }

    if (!emailRegex.hasMatch(email)) {
      return t.validation.email.invalid;
    }

    return null;
  }

  /// Validates a username.
  /// Returns error message if invalid, null if valid.
  /// Username must only contain letters, numbers, and underscores
  static String? validateUsername(String value) {
    final String username = value.trim();

    if (username.isEmpty) {
      return t.validation.required;
    }

    if (username.length < UsernameValidation.minLength) {
      return t.validation.username.tooShort(minLength: UsernameValidation.minLength);
    }

    if (username.length > UsernameValidation.maxLength) {
      return t.validation.username.tooLong(maxLength: UsernameValidation.maxLength);
    }

    if (!UsernameValidation.hasValidCharacters(username)) {
      return t.validation.username.invalidFormat;
    }

    return null;
  }

  /// Validates a first name.
  /// Returns error message if invalid, null if valid.
  static String? validateFirstName(String value) {
    final String firstName = value.trim();

    if (firstName.isEmpty) {
      return t.validation.required;
    }

    if (firstName.length < FirstNameValidation.minLength) {
      return t.validation.name.tooShort(minLength: FirstNameValidation.minLength);
    }

    if (firstName.length > FirstNameValidation.maxLength) {
      return t.validation.name.tooLong(maxLength: FirstNameValidation.maxLength);
    }

    return null;
  }

  /// Validates a last name.
  /// Returns error message if invalid, null if valid.
  static String? validateLastName(String value) {
    final String lastName = value.trim();

    if (lastName.isEmpty) {
      return t.validation.required;
    }

    if (lastName.length < LastNameValidation.minLength) {
      return t.validation.name.tooShort(minLength: LastNameValidation.minLength);
    }

    if (lastName.length > LastNameValidation.maxLength) {
      return t.validation.name.tooLong(maxLength: LastNameValidation.maxLength);
    }

    return null;
  }

  /// Validates a password.
  /// Returns error message if invalid, null if valid.
  static String? validatePassword(String value) {
    final String password = value.trim();

    if (password.isEmpty) {
      return t.validation.required;
    }

    if (!PasswordValidation.isValid(password)) {
      return t.validation.password.tooShort(minLength: PasswordValidation.minLength);
    }

    return null;
  }

  /// Validates confirm password matches password.
  /// Returns error message if invalid, null if valid.
  static String? validateConfirmPassword(String confirmPassword, String password) {
    final String trimmedConfirm = confirmPassword.trim();
    final String trimmedPassword = password.trim();

    if (trimmedConfirm.isEmpty) {
      return t.validation.required;
    }

    if (trimmedConfirm != trimmedPassword) {
      return t.validation.password.doNotMatch;
    }

    return null;
  }
}
