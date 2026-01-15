/// Response model for user profile endpoints.
///
/// Returned by `GET /api/v1/users/me/profile`, `GET /api/v1/users/{id}/profile`,
/// and `PUT /api/v1/users/{id}/profile`.
class ProfileResponse {
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

  /// When the profile was created.
  final DateTime? createdAt;

  /// When the profile was last updated.
  final DateTime? updatedAt;

  /// Creates a new [ProfileResponse].
  const ProfileResponse({
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isOnboarding = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [ProfileResponse] from a JSON map.
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isOnboarding: json['isOnboarding'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  /// Converts this [ProfileResponse] to a JSON map.
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ProfileResponse(id: $id, email: $email, username: $username)';
  }
}
