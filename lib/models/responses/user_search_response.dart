import 'package:rally/models/responses/profile_response.dart';

/// Response model for user search results.
///
/// Returned by `GET /api/v1/user/search`.
class UserSearchResponse {
  /// The current page number.
  final int page;

  /// The number of results per page.
  final int pageSize;

  /// The total number of results found.
  final int total;

  /// The total number of pages.
  final int totalPages;

  /// The list of users found.
  final List<ProfileResponse> users;

  /// Creates a new [UserSearchResponse].
  const UserSearchResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.users,
  });

  /// Creates a [UserSearchResponse] from a JSON map.
  factory UserSearchResponse.fromJson(Map<String, dynamic> json) {
    return UserSearchResponse(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      users:
          (json['users'] as List<dynamic>?)
              ?.map((dynamic e) => ProfileResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <ProfileResponse>[],
    );
  }
}
