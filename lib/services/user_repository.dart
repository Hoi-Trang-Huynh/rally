import 'package:rally/models/responses/availability_response.dart';
import 'package:rally/models/responses/follow_list_response.dart';
import 'package:rally/models/responses/follow_response.dart';
import 'package:rally/models/responses/follow_status_response.dart';
import 'package:rally/models/responses/friend_list_response.dart';
import 'package:rally/models/responses/login_response.dart';
import 'package:rally/models/responses/profile_details_response.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/models/responses/register_response.dart';
import 'package:rally/models/responses/user_public_profile_response.dart';
import 'package:rally/models/responses/user_search_response.dart';
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
  Future<LoginResponse> login({required String idToken}) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/auth/login',
      body: <String, dynamic>{'id_token': idToken},
    );
    return LoginResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Registers a new user or logs in via Firebase ID token.
  ///
  /// Accepts a Firebase ID token and returns user info.
  /// If the user is new, they will be registered.
  /// Returns a [RegisterResponse] containing user data and message.
  Future<RegisterResponse> register({required String idToken}) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/auth/register',
      body: <String, dynamic>{'id_token': idToken},
    );
    return RegisterResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Checks if an email is available for registration.
  ///
  /// Returns an [AvailabilityResponse] with availability status.
  Future<AvailabilityResponse> checkEmailAvailability(String email) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/auth/check-email',
      queryParams: <String, String>{'email': email},
    );
    return AvailabilityResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Checks if a username is available for registration.
  ///
  /// Returns an [AvailabilityResponse] with availability status.
  Future<AvailabilityResponse> checkUsernameAvailability(String username) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/auth/check-username',
      queryParams: <String, String>{'username': username},
    );
    return AvailabilityResponse.fromJson(response as Map<String, dynamic>);
  }

  // ============================================
  // User Profile Endpoints
  // ============================================

  /// Fetches the current user's profile from the backend.
  ///
  /// Requires Bearer Firebase ID Token in the Authorization header.
  /// Returns a [ProfileResponse] containing profile data.
  Future<ProfileResponse> getMyProfile() async {
    final dynamic response = await _apiClient.get('/api/v1/user/me/profile');
    return ProfileResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Fetches the current user's detailed profile (including bio).
  ///
  /// Requires Bearer Firebase ID Token in the Authorization header.
  /// Returns a [ProfileDetailsResponse] containing bio and other details.
  Future<ProfileDetailsResponse> getMyProfileDetails() async {
    final dynamic response = await _apiClient.get('/api/v1/user/me/profile/details');
    return ProfileDetailsResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Fetches a specific user's public profile by ID.
  ///
  /// [userId] The ID of the user to fetch.
  /// Returns a [UserPublicProfileResponse] containing public profile data.
  Future<UserPublicProfileResponse> getUserPublicProfile(String userId) async {
    final dynamic response = await _apiClient.get('/api/v1/user/$userId/profile');
    return UserPublicProfileResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Updates the current user's profile.
  ///
  /// [userId] The ID of the user to update.
  /// All parameters are optional; only provided fields will be updated.
  /// Returns a [ProfileResponse] containing the updated profile data.
  Future<ProfileResponse> updateUserProfile({
    required String userId,
    String? username,
    String? firstName,
    String? lastName,
    String? bioText,
    String? phoneNumber,
    String? avatarUrl,
    bool? isActive,
    bool? isEmailVerified,
    bool? isOnboarding,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{
      if (username != null) 'username': username,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (bioText != null) 'bioText': bioText,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (isActive != null) 'isActive': isActive,
      if (isEmailVerified != null) 'isEmailVerified': isEmailVerified,
      if (isOnboarding != null) 'isOnboarding': isOnboarding,
    };

    final dynamic response = await _apiClient.put('/api/v1/user/$userId/profile', body: body);
    return ProfileResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Searches for users by query string.
  ///
  /// [query] The search query (username, first name, or last name).
  /// [page] The page number (default: 1).
  /// [pageSize] The number of results per page (default: 20).
  /// Returns a [UserSearchResponse] containing search results.
  Future<UserSearchResponse> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/user/search',
      queryParams: <String, String>{
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );
    return UserSearchResponse.fromJson(response as Map<String, dynamic>);
  }

  // ============================================
  // Follow Endpoints
  // ============================================

  /// Checks if the authenticated user follows the target user.
  ///
  /// [userId] The ID of the user to check follow status for.
  /// Returns a [FollowStatusResponse] containing the follow status.
  Future<FollowStatusResponse> getFollowStatus(String userId) async {
    final dynamic response = await _apiClient.get('/api/v1/user/$userId/follow/status');
    return FollowStatusResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Follows a user.
  ///
  /// [userId] The ID of the user to follow.
  /// Returns a [FollowResponse] containing the result.
  Future<FollowResponse> followUser(String userId) async {
    final dynamic response = await _apiClient.post('/api/v1/user/$userId/follow');
    return FollowResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Unfollows a user.
  ///
  /// [userId] The ID of the user to unfollow.
  /// Returns a [FollowResponse] containing the result.
  Future<FollowResponse> unfollowUser(String userId) async {
    final dynamic response = await _apiClient.delete('/api/v1/user/$userId/follow');
    return FollowResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Gets a paginated list of users who follow the specified user.
  ///
  /// [userId] The ID of the user to get followers for.
  /// [page] The page number (default: 1).
  /// [pageSize] The number of results per page (default: 20).
  /// Returns a [FollowListResponse] containing the followers list.
  Future<FollowListResponse> getFollowers({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/user/$userId/followers',
      queryParams: <String, String>{'page': page.toString(), 'pageSize': pageSize.toString()},
    );
    return FollowListResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Gets a paginated list of users that the specified user follows.
  ///
  /// [userId] The ID of the user to get following for.
  /// [page] The page number (default: 1).
  /// [pageSize] The number of results per page (default: 20).
  /// Returns a [FollowListResponse] containing the following list.
  Future<FollowListResponse> getFollowing({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/user/$userId/following',
      queryParams: <String, String>{'page': page.toString(), 'pageSize': pageSize.toString()},
    );
    return FollowListResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Gets a paginated list of mutual friends (users who follow each other).
  ///
  /// [userId] The ID of the user to get friends for.
  /// [query] Optional search query (matches username, first name, or last name).
  /// [page] The page number (default: 1).
  /// [pageSize] The number of results per page (default: 20).
  /// Returns a [FriendListResponse] containing the friends list.
  Future<FriendListResponse> getFriends({
    required String userId,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final dynamic response = await _apiClient.get(
      '/api/v1/user/$userId/friends',
      queryParams: queryParams,
    );
    return FriendListResponse.fromJson(response as Map<String, dynamic>);
  }
}
