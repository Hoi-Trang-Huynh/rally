/// Response model for email/username availability checks.
///
/// Returned by `GET /api/v1/auth/check-email` and `GET /api/v1/auth/check-username`.
class AvailabilityResponse {
  /// Whether the email/username is available.
  final bool available;

  /// Status message describing the availability.
  final String? message;

  /// Creates a new [AvailabilityResponse].
  const AvailabilityResponse({required this.available, this.message});

  /// Creates an [AvailabilityResponse] from a JSON map.
  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilityResponse(
      available: json['available'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  /// Converts this [AvailabilityResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'available': available, 'message': message};
  }

  @override
  String toString() {
    return 'AvailabilityResponse(available: $available, message: $message)';
  }
}
