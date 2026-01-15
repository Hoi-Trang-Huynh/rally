/// Response model for detailed profile information.
///
/// Returned by `GET /api/v1/user/me/profile/details`.
/// Contains additional profile fields like bio for the profile page view.
class ProfileDetailsResponse {
  /// The MongoDB document ID.
  final String id;

  /// The user's bio text.
  final String? bioText;

  /// Creates a new [ProfileDetailsResponse].
  const ProfileDetailsResponse({required this.id, this.bioText});

  /// Creates a [ProfileDetailsResponse] from a JSON map.
  factory ProfileDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProfileDetailsResponse(
      id: json['id'] as String? ?? '',
      bioText: json['bioText'] as String?,
    );
  }

  /// Converts this [ProfileDetailsResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'bioText': bioText};
  }

  @override
  String toString() {
    return 'ProfileDetailsResponse(id: $id, bioText: $bioText)';
  }
}
