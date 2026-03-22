import 'package:rally/models/enums.dart';

/// Response model for a single rally item in user's rallies list.
///
/// Contains only essential fields for list views.
/// Used by `GET /user/{id}/rallies`.
class UserRallyItem {
  /// The rally ID.
  final String id;

  /// The rally name.
  final String name;

  /// When the rally starts.
  final DateTime? startDate;

  /// When the rally ends.
  final DateTime? endDate;

  /// Status of the rally (draft, active, inactive, completed, archived).
  final RallyStatus status;

  /// When the rally was last updated.
  final DateTime? updatedAt;

  /// Creates a new [UserRallyItem].
  const UserRallyItem({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    required this.status,
    this.updatedAt,
  });

  /// Creates a [UserRallyItem] from a JSON map.
  factory UserRallyItem.fromJson(Map<String, dynamic> json) {
    return UserRallyItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      status: RallyStatus.fromString(json['status'] as String? ?? 'draft'),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  /// Converts this [UserRallyItem] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserRallyItem(id: $id, name: $name, status: ${status.name})';
  }
}

/// Response model for user's rallies list.
///
/// Returned by `GET /user/{id}/rallies`.
/// Contains a filtered and sorted list of rallies where the user is a participant.
class UserRalliesResponse {
  /// List of rally items.
  final List<UserRallyItem> rallies;

  /// Total number of rallies matching the filter.
  final int total;

  /// The current page number.
  final int page;

  /// The number of results per page.
  final int pageSize;

  /// The total number of pages.
  final int totalPages;

  /// Creates a new [UserRalliesResponse].
  const UserRalliesResponse({
    required this.rallies,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  /// Creates a [UserRalliesResponse] from a JSON map.
  factory UserRalliesResponse.fromJson(Map<String, dynamic> json) {
    return UserRalliesResponse(
      rallies: (json['rallies'] as List<dynamic>?)
              ?.map((dynamic e) => UserRallyItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <UserRallyItem>[],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  /// Converts this [UserRalliesResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rallies': rallies.map((UserRallyItem e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
    };
  }

  @override
  String toString() {
    return 'UserRalliesResponse(total: $total, page: $page, rallies: ${rallies.length})';
  }
}
