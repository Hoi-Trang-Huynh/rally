import 'package:rally/models/responses/user_response.dart';

/// Response model for the login endpoint.
///
/// Returned by `POST /api/v1/auth/login`.
class LoginResponse {
  /// Status message (e.g., "Login successful").
  final String message;

  /// The authenticated user's data.
  final UserResponse user;

  /// Creates a new [LoginResponse].
  const LoginResponse({required this.message, required this.user});

  /// Creates a [LoginResponse] from a JSON map.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String? ?? '',
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
    );
  }

  /// Converts this [LoginResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'message': message, 'user': user.toJson()};
  }

  @override
  String toString() {
    return 'LoginResponse(message: $message, user: $user)';
  }
}
