/// A single user item in search results.
///
/// Matches the backend `UserSearchResult` shape returned by `GET /api/v1/user/search`.
/// Contains only the fields needed for search result display.
class UserSearchResult {
  /// The MongoDB document ID.
  final String id;

  /// The user's username.
  final String username;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The URL of the user's avatar.
  final String? avatarUrl;

  /// Creates a new [UserSearchResult].
  const UserSearchResult({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  /// Creates a [UserSearchResult] from a JSON map.
  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Converts this [UserSearchResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
    };
  }

  @override
  String toString() {
    return 'UserSearchResult(id: $id, username: $username)';
  }
}
