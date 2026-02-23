import 'package:rally/models/enums.dart';

/// Response model for rally participant list endpoint.
///
/// Returned by `GET /api/v1/rallies/{id}/participants`
class ParticipantListResponse {
  /// The current page number.
  final int page;

  /// The number of results per page.
  final int pageSize;

  /// The total number of results found.
  final int total;

  /// The total number of pages.
  final int totalPages;

  /// The list of participants.
  final List<ParticipantItem> participants;

  /// Creates a new [ParticipantListResponse].
  const ParticipantListResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.participants,
  });

  /// Creates a [ParticipantListResponse] from a JSON map.
  factory ParticipantListResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantListResponse(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((dynamic e) => ParticipantItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <ParticipantItem>[],
    );
  }
}

/// Minimal user info embedded in participant responses.
///
/// Used for both the participant's own user details and the inviter's details.
class ParticipantUserInfo {
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

  /// Creates a new [ParticipantUserInfo].
  const ParticipantUserInfo({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  /// Creates a [ParticipantUserInfo] from a JSON map.
  factory ParticipantUserInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantUserInfo(
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

/// A single participant item in the rally participants list.
class ParticipantItem {
  /// The participant record's unique ID.
  final String id;

  /// The participant's user details.
  final ParticipantUserInfo user;

  /// The participant's role in the rally.
  final ParticipantRole role;

  /// The participant's status in the rally.
  final ParticipationStatus status;

  /// The user who invited this participant, if available.
  final ParticipantUserInfo? invitedBy;

  /// When the participant was invited, if applicable.
  final DateTime? invitedAt;

  /// When the participant joined, if applicable.
  final DateTime? joinedAt;

  /// Creates a new [ParticipantItem].
  const ParticipantItem({
    required this.id,
    required this.user,
    required this.role,
    required this.status,
    this.invitedBy,
    this.invitedAt,
    this.joinedAt,
  });

  /// Creates a [ParticipantItem] from a JSON map.
  factory ParticipantItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? userJson = json['user'] as Map<String, dynamic>?;
    final Map<String, dynamic>? inviterJson = json['invitedBy'] as Map<String, dynamic>?;

    return ParticipantItem(
      id: json['id'] as String? ?? '',
      user:
          userJson != null
              ? ParticipantUserInfo.fromJson(userJson)
              : const ParticipantUserInfo(id: '', username: ''),
      role: ParticipantRole.fromString(json['role'] as String? ?? 'participant'),
      status: ParticipationStatus.fromString(json['status'] as String? ?? 'invited'),
      invitedBy: inviterJson != null ? ParticipantUserInfo.fromJson(inviterJson) : null,
      invitedAt: json['invitedAt'] != null ? DateTime.tryParse(json['invitedAt'] as String) : null,
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) : null,
    );
  }

  /// Convenience getters that delegate to [user].
  String get userId => user.id;

  /// The user's username.
  String get username => user.username;

  /// The URL of the user's avatar.
  String? get avatarUrl => user.avatarUrl;

  /// Returns the user's full display name.
  String get displayName => user.displayName;
}
