import 'package:rally/models/responses/follow_list_response.dart';

/// Response model for friends list endpoint.
///
/// Returned by `GET /api/v1/user/{id}/friends`
/// Friends are mutual follows - users who follow each other.
class FriendListResponse {
  /// The current page number.
  final int page;

  /// The number of results per page.
  final int pageSize;

  /// The total number of results found.
  final int total;

  /// The total number of pages.
  final int totalPages;

  /// The list of friend users.
  /// Reuses [FollowUserItem] since the structure is identical.
  final List<FollowUserItem> users;

  /// Creates a new [FriendListResponse].
  const FriendListResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.users,
  });

  /// Creates a [FriendListResponse] from a JSON map.
  factory FriendListResponse.fromJson(Map<String, dynamic> json) {
    return FriendListResponse(
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
