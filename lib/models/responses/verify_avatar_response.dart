/// Response model for the verify-avatar endpoint.
///
/// Returned by `POST /api/v1/media/verify-avatar`.
class VerifyAvatarResponse {
  /// Success message from the server.
  final String message;

  /// The avatar URL that was verified and saved.
  final String url;

  /// Creates a new [VerifyAvatarResponse].
  const VerifyAvatarResponse({
    required this.message,
    required this.url,
  });

  /// Creates a [VerifyAvatarResponse] from a JSON map.
  factory VerifyAvatarResponse.fromJson(Map<String, dynamic> json) {
    return VerifyAvatarResponse(
      message: json['message'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
