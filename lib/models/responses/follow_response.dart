/// Response model for follow/unfollow actions.
///
/// Used by POST and DELETE /user/{id}/follow endpoints.
class FollowResponse {
  /// Whether the action was successful.
  final bool success;

  /// Current follow status after the action.
  final bool isFollowing;

  /// Message describing the result.
  final String message;

  /// Creates a new [FollowResponse].
  const FollowResponse({required this.success, required this.isFollowing, required this.message});

  /// Creates a [FollowResponse] from JSON.
  factory FollowResponse.fromJson(Map<String, dynamic> json) {
    return FollowResponse(
      success: json['success'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'success': success, 'isFollowing': isFollowing, 'message': message};
  }
}
