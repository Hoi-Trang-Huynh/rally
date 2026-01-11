import 'package:firebase_auth/firebase_auth.dart';
import 'package:rally/models/responses/profile_response.dart';

/// Represents a user in the application.
///
/// This class wraps user data from both Firebase and the backend API,
/// providing a consistent interface for user data throughout the app.
class AppUser {
  /// The Firebase UID (used for authentication).
  final String uid;

  /// The MongoDB document ID.
  final String? id;

  /// The user's email address.
  final String? email;

  /// The user's username.
  final String? username;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The URL of the user's avatar.
  final String? avatarUrl;

  /// Whether the user's email has been verified.
  final bool isEmailVerified;

  /// Whether the user is still in the onboarding flow.
  final bool isOnboarding;

  /// Creates a new [AppUser].
  const AppUser({
    required this.uid,
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.isOnboarding = true,
  });

  /// Factory constructor to create an [AppUser] from a Firebase [User].
  ///
  /// This is used as a fallback when backend profile is not available.
  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      username: user.displayName,
      avatarUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }

  /// Factory constructor to create an empty [AppUser].
  factory AppUser.fromEmpty() {
    return const AppUser(
      uid: '',
      id: '',
      email: '',
      username: '',
      firstName: '',
      lastName: '',
      avatarUrl: '',
      isEmailVerified: false,
      isOnboarding: true,
    );
  }

  /// Factory constructor to create an [AppUser] from backend profile response.
  ///
  /// [firebaseUid] is required as the backend doesn't return the Firebase UID.
  /// [profileData] is the response from `/api/v1/users/me/profile`.
  factory AppUser.fromBackendProfile({
    required String firebaseUid,
    required Map<String, dynamic> profileData,
  }) {
    return AppUser(
      uid: firebaseUid,
      id: profileData['id'] as String?,
      email: profileData['email'] as String?,
      username: profileData['username'] as String?,
      firstName: profileData['firstName'] as String?,
      lastName: profileData['lastName'] as String?,
      avatarUrl: profileData['avatarUrl'] as String?,
      isEmailVerified: profileData['isEmailVerified'] as bool? ?? false,
      isOnboarding: profileData['isOnboarding'] as bool? ?? true,
    );
  }

  /// Factory constructor to create an [AppUser] from a [ProfileResponse].
  ///
  /// [firebaseUid] is required as the backend doesn't return the Firebase UID.
  /// [profile] is the typed profile response from the backend.
  factory AppUser.fromProfileResponse({
    required String firebaseUid,
    required ProfileResponse profile,
  }) {
    return AppUser(
      uid: firebaseUid,
      id: profile.id,
      email: profile.email,
      username: profile.username,
      firstName: profile.firstName,
      lastName: profile.lastName,
      avatarUrl: profile.avatarUrl,
      isEmailVerified: profile.isEmailVerified,
      isOnboarding: profile.isOnboarding,
    );
  }

  /// Returns true if the user needs to complete their profile.
  ///
  /// This is used to detect Google Sign-In users who haven't filled in
  /// their username, firstName, or lastName yet.
  /// Checks for both null and empty strings.
  bool get needsProfileCompletion =>
      (username == null || username!.isEmpty) ||
      (firstName == null || firstName!.isEmpty) ||
      (lastName == null || lastName!.isEmpty);

  @override
  String toString() {
    return 'AppUser(uid: $uid, id: $id, email: $email, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.uid == uid &&
        other.id == id &&
        other.email == email &&
        other.username == username &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.avatarUrl == avatarUrl &&
        other.isEmailVerified == isEmailVerified &&
        other.isOnboarding == isOnboarding;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        avatarUrl.hashCode ^
        isEmailVerified.hashCode ^
        isOnboarding.hashCode;
  }
}
