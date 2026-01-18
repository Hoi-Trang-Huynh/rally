/// Response model for checking follow status.
///
/// Used by GET /user/{id}/follow/status endpoint.
class FollowStatusResponse {
  /// Whether the authenticated user is following the target user.
  final bool isFollowing;

  /// Creates a new [FollowStatusResponse].
  const FollowStatusResponse({required this.isFollowing});

  /// Creates a [FollowStatusResponse] from JSON.
  factory FollowStatusResponse.fromJson(Map<String, dynamic> json) {
    return FollowStatusResponse(isFollowing: json['isFollowing'] as bool? ?? false);
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'isFollowing': isFollowing};
  }
}
