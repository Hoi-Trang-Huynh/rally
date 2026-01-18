/// Response model for public user profile.
///
/// Returned by `GET /api/v1/user/{id}/profile`.
/// Contains public profile data including follow counts.
class UserPublicProfileResponse {
  /// The MongoDB document ID.
  final String? id;

  /// The user's username.
  final String? username;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The URL of the user's avatar.
  final String? avatarUrl;

  /// The user's bio text.
  final String? bioText;

  /// The number of followers.
  final int followersCount;

  /// The number of users being followed.
  final int followingCount;

  /// Creates a new [UserPublicProfileResponse].
  const UserPublicProfileResponse({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.bioText,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  /// Creates a [UserPublicProfileResponse] from a JSON map.
  factory UserPublicProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserPublicProfileResponse(
      id: json['id'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bioText: json['bioText'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }

  /// Converts this [UserPublicProfileResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'bioText': bioText,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  @override
  String toString() {
    return 'UserPublicProfileResponse(id: $id, username: $username, followers: $followersCount)';
  }
}
