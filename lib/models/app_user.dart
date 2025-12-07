import 'package:firebase_auth/firebase_auth.dart';

/// Represents a user in the application.
///
/// This class wraps the Firebase [User] and provides a consistent interface
/// for user data throughout the app.
class AppUser {
  /// The unique identifier for the user.
  final String uid;

  /// The user's email address.
  final String? email;

  /// The user's display name.
  final String? displayName;

  /// The URL of the user's profile photo.
  final String? photoUrl;

  /// Whether the user's email has been verified.
  final bool emailVerified;

  /// Whether the user has completed the onboarding flow.
  /// This will be fetched from Firestore in the future.
  final bool hasCompletedOnboarding;

  /// Creates a new [AppUser].
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.hasCompletedOnboarding = false,
  });

  /// Factory constructor to create an [AppUser] from a Firebase [User].
  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.emailVerified == emailVerified &&
        other.hasCompletedOnboarding == hasCompletedOnboarding;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode ^
        emailVerified.hashCode ^
        hasCompletedOnboarding.hashCode;
  }
}
