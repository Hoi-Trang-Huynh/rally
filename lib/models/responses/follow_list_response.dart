/// Response model for followers/following list endpoints.
///
/// Returned by:
/// - `GET /api/v1/user/{id}/followers`
/// - `GET /api/v1/user/{id}/following`
class FollowListResponse {
  /// The current page number.
  final int page;

  /// The number of results per page.
  final int pageSize;

  /// The total number of results found.
  final int total;

  /// The total number of pages.
  final int totalPages;

  /// The list of users.
  final List<FollowUserItem> users;

  /// Creates a new [FollowListResponse].
  const FollowListResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.users,
  });

  /// Creates a [FollowListResponse] from a JSON map.
  factory FollowListResponse.fromJson(Map<String, dynamic> json) {
    return FollowListResponse(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      users:
          (json['users'] as List<dynamic>?)
              ?.map((dynamic e) => FollowUserItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <FollowUserItem>[],
    );
  }
}

/// A single user item in the followers/following list.
class FollowUserItem {
  /// The user's unique ID.
  final String id;

  /// The user's username.
  final String username;

  /// The user's first name.
  final String? firstName;

  /// The user's last name.
  final String? lastName;

  /// The URL of the user's avatar.
  final String? avatarUrl;

  /// Creates a new [FollowUserItem].
  const FollowUserItem({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  /// Creates a [FollowUserItem] from a JSON map.
  factory FollowUserItem.fromJson(Map<String, dynamic> json) {
    return FollowUserItem(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Returns the user's full display name.
  String get displayName {
    final String first = firstName ?? '';
    final String last = lastName ?? '';
    final String fullName = '$first $last'.trim();
    return fullName.isNotEmpty ? fullName : username;
  }
}
