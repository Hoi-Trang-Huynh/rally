/// Response model for user data returned in login/register responses.
///
/// This is the base user object returned by authentication endpoints.
class UserResponse {
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

  /// Whether the user account is active.
  final bool isActive;

  /// Whether the user's email has been verified.
  final bool isEmailVerified;

  /// Whether the user is still in the onboarding flow.
  final bool isOnboarding;

  /// Creates a new [UserResponse].
  const UserResponse({
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isOnboarding = true,
  });

  /// Creates a [UserResponse] from a JSON map.
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isOnboarding: json['isOnboarding'] as bool? ?? true,
    );
  }

  /// Converts this [UserResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isOnboarding': isOnboarding,
    };
  }

  @override
  String toString() {
    return 'UserResponse(id: $id, email: $email, username: $username)';
  }
}
