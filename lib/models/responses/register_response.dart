import 'package:rally/models/responses/user_response.dart';

/// Response model for the register endpoint.
///
/// Returned by `POST /api/v1/auth/register`.
class RegisterResponse {
  /// Status message (e.g., "Registration successful").
  final String message;

  /// The registered user's data.
  final UserResponse user;

  /// Creates a new [RegisterResponse].
  const RegisterResponse({required this.message, required this.user});

  /// Creates a [RegisterResponse] from a JSON map.
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String? ?? '',
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }

  /// Converts this [RegisterResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'message': message, 'user': user.toJson()};
  }

  @override
  String toString() {
    return 'RegisterResponse(message: $message, user: $user)';
  }
}
