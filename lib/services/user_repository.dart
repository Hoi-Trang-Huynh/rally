import 'package:rally/services/api_client.dart';

/// Repository for user-related API calls.
///
/// Handles communication with the backend for user profile data
/// stored in MongoDB.
class UserRepository {
  final ApiClient _apiClient;

  /// Creates a new [UserRepository].
  UserRepository(this._apiClient);

  /// Creates a new user profile in the backend.
  ///
  /// Called after Firebase account creation to store additional user data.
  Future<Map<String, dynamic>> createUser({
    required String firebaseUid,
    required String email,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/users',
      body: <String, dynamic>{
        'firebase_uid': firebaseUid,
        'email': email,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Fetches the current user's profile from the backend.
  Future<Map<String, dynamic>> getUser() async {
    final dynamic response = await _apiClient.get('/api/v1/users/me');
    return response as Map<String, dynamic>;
  }

  /// Updates the current user's profile.
  Future<Map<String, dynamic>> updateUser({
    String? username,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (photoUrl != null) 'photo_url': photoUrl,
    };

    final dynamic response = await _apiClient.put('/api/v1/users/me', body: body);
    return response as Map<String, dynamic>;
  }

  /// Checks if an email is already registered.
  ///
  /// Returns true if the email exists, false otherwise.
  Future<bool> checkEmailExists(String email) async {
    try {
      final dynamic response = await _apiClient.get(
        '/api/v1/users/check-email',
        queryParams: <String, String>{'email': email},
      );
      final Map<String, dynamic> data = response as Map<String, dynamic>;
      return data['exists'] as bool? ?? false;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  /// Checks if a username is already taken.
  ///
  /// Returns true if the username exists, false otherwise.
  Future<bool> checkUsernameExists(String username) async {
    try {
      final dynamic response = await _apiClient.get(
        '/api/v1/users/check-username',
        queryParams: <String, String>{'username': username},
      );
      final Map<String, dynamic> data = response as Map<String, dynamic>;
      return data['exists'] as bool? ?? false;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }

  /// Marks the user's onboarding as completed.
  Future<void> completeOnboarding() async {
    await _apiClient.put('/api/v1/users/me/onboarding');
  }
}
