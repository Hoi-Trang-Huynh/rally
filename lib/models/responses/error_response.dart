/// Response model for API error responses.
///
/// Returned when API requests fail (400, 401, 404, etc.).
class ErrorResponse {
  /// The error message.
  final String message;

  /// Creates a new [ErrorResponse].
  const ErrorResponse({required this.message});

  /// Creates an [ErrorResponse] from a JSON map.
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(message: json['message'] as String? ?? 'Unknown error');
  }

  /// Converts this [ErrorResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'message': message};
  }

  @override
  String toString() {
    return 'ErrorResponse(message: $message)';
  }
}
