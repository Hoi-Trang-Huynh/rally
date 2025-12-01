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

  /// Creates a new [AppUser].
  const AppUser({required this.uid, this.email, this.displayName, this.photoUrl});

  /// Factory constructor to create an [AppUser] from a Firebase [User].
  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
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
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ displayName.hashCode ^ photoUrl.hashCode;
  }
}
