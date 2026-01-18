/// Response model for detailed profile information.
///
/// Returned by `GET /api/v1/user/me/profile/details`.
/// Contains additional profile fields like bio and follow counts for the profile page view.
class ProfileDetailsResponse {
  /// The MongoDB document ID.
  final String id;

  /// The user's bio text.
  final String? bioText;

  /// The number of followers.
  final int followersCount;

  /// The number of users being followed.
  final int followingCount;

  /// Creates a new [ProfileDetailsResponse].
  const ProfileDetailsResponse({
    required this.id,
    this.bioText,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  /// Creates a [ProfileDetailsResponse] from a JSON map.
  factory ProfileDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProfileDetailsResponse(
      id: json['id'] as String? ?? '',
      bioText: json['bioText'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }

  /// Converts this [ProfileDetailsResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'bioText': bioText,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  @override
  String toString() {
    return 'ProfileDetailsResponse(id: $id, bioText: $bioText, followersCount: $followersCount, followingCount: $followingCount)';
  }
}
