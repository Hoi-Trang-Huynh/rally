import 'package:rally/models/responses/feedback_response.dart';
import 'package:rally/services/api_client.dart';

/// Repository for feedback-related API calls.
///
/// Handles communication with the backend for submitting user feedback.
class FeedbackRepository {
  final ApiClient _apiClient;

  /// Creates a new [FeedbackRepository].
  FeedbackRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Submits user feedback to the backend.
  ///
  /// [username] The username of the feedback submitter (required).
  /// [comment] The feedback comment text (required).
  /// [categories] List of category values (e.g., 'ui', 'bug', 'feature').
  /// [avatarUrl] Optional avatar URL of the submitter.
  /// [attachmentUrls] Optional list of attachment URLs.
  /// Returns a [FeedbackResponse] containing the created feedback.
  Future<FeedbackResponse> submitFeedback({
    required String username,
    required String comment,
    required List<String> categories,
    String? avatarUrl,
    List<String>? attachmentUrls,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'username': username,
      'comment': comment,
      'categories': categories,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (attachmentUrls != null) 'attachmentUrls': attachmentUrls,
    };

    final dynamic response = await _apiClient.post('/api/v1/feedback', body: body);
    return FeedbackResponse.fromJson(response as Map<String, dynamic>);
  }
}
