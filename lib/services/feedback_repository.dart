import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/responses/feedback_response.dart';
import 'package:rally/providers/api_provider.dart';
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
  /// [imageUrl] Optional image URL attached to feedback.
  /// Returns a [FeedbackResponse] containing the created feedback.
  Future<FeedbackResponse> submitFeedback({
    required String username,
    required String comment,
    required List<String> categories,
    String? avatarUrl,
    String? imageUrl,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'username': username,
      'comment': comment,
      'categories': categories,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (imageUrl != null) 'image_url': imageUrl,
    };

    final dynamic response = await _apiClient.post('/api/v1/feedback', body: body);
    return FeedbackResponse.fromJson(response as Map<String, dynamic>);
  }
}

/// Provider for [FeedbackRepository].
final Provider<FeedbackRepository> feedbackRepositoryProvider = Provider<FeedbackRepository>((
  Ref ref,
) {
  final ApiClient apiClient = ref.watch(apiClientProvider);
  return FeedbackRepository(apiClient: apiClient);
});
