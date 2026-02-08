/// Validation constants for form fields across the app.
///
/// This file contains all validation-related constants to ensure
/// consistent validation rules throughout the application.
library;

/// Username validation constants.
class UsernameValidation {
  /// Minimum length for username.
  static const int minLength = 5;

  /// Maximum length for username.
  static const int maxLength = 15;

  /// Regex pattern for valid username format.
  /// Only allows letters (a-z, A-Z), numbers (0-9), and underscores (_).
  /// Must start with a letter.
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

  /// Check if username contains only valid characters (letters, numbers, underscores).
  static bool hasValidCharacters(String username) => usernameRegex.hasMatch(username);

  /// Check if username meets length requirements.
  static bool hasValidLength(String username) =>
      username.length >= minLength && username.length <= maxLength;

  /// Check if username meets all requirements.
  static bool isValid(String username) => hasValidLength(username) && hasValidCharacters(username);
}

/// First name validation constants.
class FirstNameValidation {
  /// Minimum length for first name.
  static const int minLength = 2;

  /// Maximum length for first name.
  static const int maxLength = 15;
}

/// Last name validation constants.
class LastNameValidation {
  /// Minimum length for last name.
  static const int minLength = 2;

  /// Maximum length for last name.
  static const int maxLength = 15;
}

/// Bio validation constants.
class BioValidation {
  /// Maximum length for bio.
  static const int maxLength = 50;
}

/// Password validation constants and rules.
class PasswordValidation {
  /// Minimum length for password.
  static const int minLength = 8;

  /// Maximum length for password.
  static const int maxLength = 128;

  /// Check if password contains at least one uppercase letter.
  static bool hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));

  /// Check if password contains at least one lowercase letter.
  static bool hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));

  /// Check if password contains at least one digit.
  static bool hasDigit(String password) => password.contains(RegExp(r'[0-9]'));

  /// Check if password meets minimum length requirement.
  static bool hasMinLength(String password) => password.length >= minLength;

  /// Check if password meets all requirements.
  static bool isValid(String password) =>
      hasMinLength(password) &&
      hasUppercase(password) &&
      hasLowercase(password) &&
      hasDigit(password);
}

/// Image validation constants.
class ImageValidation {
  /// Maximum width for avatar/profile images.
  static const double avatarMaxWidth = 1024;

  /// Maximum height for avatar/profile images.
  static const double avatarMaxHeight = 1024;

  /// Maximum width for cover/banner images.
  static const double coverMaxWidth = 1920;

  /// Maximum height for cover/banner images.
  static const double coverMaxHeight = 1080;

  /// Default image quality for compression (0-100).
  static const int imageQuality = 85;

  /// Maximum number of feedback attachment images.
  static const int maxFeedbackImages = 3;
}

/// Rally validation constants.
class RallyValidation {
  /// Minimum length for rally name.
  static const int nameMinLength = 3;

  /// Maximum length for rally name.
  static const int nameMaxLength = 50;

  /// Maximum length for rally description.
  static const int descriptionMaxLength = 500;
}

/// Email validation regex pattern.
/// This is a simplified pattern that covers most common email formats.
final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
