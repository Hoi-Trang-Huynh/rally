import 'package:rally/services/api_client.dart';

/// Repository for user-related API calls.
///
/// Handles communication with the backend for user profile data
/// stored in MongoDB.
class UserRepository {
  final ApiClient _apiClient;

  /// Creates a new [UserRepository].
  UserRepository(this._apiClient);

  // ============================================
  // Authentication Endpoints
  // ============================================

  /// Logs in a user via Firebase ID token.
  ///
  /// Accepts a Firebase ID token and returns user info.
  /// Returns a [LoginResponse] containing user data and message.
  Future<Map<String, dynamic>> login({required String idToken}) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/auth/login',
      body: <String, dynamic>{'id_token': idToken},
    );
    return response as Map<String, dynamic>;
  }

  /// Registers a new user or logs in via Firebase ID token.
  ///
  /// Accepts a Firebase ID token and returns user info.
  /// If the user is new, they will be registered.
  /// Returns a [RegisterResponse] containing user data and message.
  Future<Map<String, dynamic>> register({required String idToken}) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/auth/register',
      body: <String, dynamic>{'id_token': idToken},
    );
    return response as Map<String, dynamic>;
  }

  // ============================================
  // User Profile Endpoints
  // ============================================

  /// Fetches the current user's profile from the backend.
  ///
  /// Requires Bearer Firebase ID Token in the Authorization header.
  /// Returns a [ProfileResponse] containing profile data.
  Future<Map<String, dynamic>> getMyProfile() async {
    final dynamic response = await _apiClient.get('/api/v1/user/me/profile');
    return response as Map<String, dynamic>;
  }

  /// Fetches a specific user's profile by ID.
  ///
  /// [userId] The ID of the user to fetch.
  /// Returns a [ProfileResponse] containing profile data.
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final dynamic response = await _apiClient.get('/api/v1/user/$userId/profile');
    return response as Map<String, dynamic>;
  }

  /// Updates the current user's profile.
  ///
  /// [userId] The ID of the user to update.
  /// All parameters are optional; only provided fields will be updated.
  /// Returns a [ProfileResponse] containing the updated profile data.
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
    String? location,
    String? phone,
    String? dateOfBirth,
    String? avatarUrl,
    bool? isEmailVerified,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (username != null) 'username': username,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (isEmailVerified != null) 'isEmailVerified': isEmailVerified,
    };

    final dynamic response = await _apiClient.put('/api/v1/user/$userId/profile', body: body);
    return response as Map<String, dynamic>;
  }
}
