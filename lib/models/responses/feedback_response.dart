/// Response model for feedback creation.
///
/// Represents a feedback entry returned from the API.
class FeedbackResponse {
  /// The unique identifier of the feedback.
  final String id;

  /// The username of the feedback submitter.
  final String username;

  /// The avatar URL of the submitter.
  final String? avatarUrl;

  /// The feedback comment text.
  final String comment;

  /// List of attachment URLs for the feedback.
  final List<String> attachmentUrls;

  /// List of category values for the feedback.
  final List<String> categories;

  /// Whether the feedback has been resolved.
  final bool resolved;

  /// When the feedback was created.
  final DateTime? createdAt;

  /// When the feedback was last updated.
  final DateTime? updatedAt;

  /// Creates a new [FeedbackResponse].
  const FeedbackResponse({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.comment,
    this.attachmentUrls = const <String>[],
    required this.categories,
    required this.resolved,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [FeedbackResponse] from JSON.
  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      comment: json['comment'] as String? ?? '',
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)?.map((dynamic e) => e as String).toList() ??
          <String>[],
      categories:
          (json['categories'] as List<dynamic>?)?.map((dynamic e) => e as String).toList() ??
          <String>[],
      resolved: json['resolved'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'comment': comment,
      'attachmentUrls': attachmentUrls,
      'categories': categories,
      'resolved': resolved,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
