import 'package:rally/models/enums.dart';

/// A single pending rally invitation for the current user.
///
/// Returned as part of `GET /api/v1/user/me/invitations`.
class PendingInvitationItem {
  /// The participant record ID.
  final String participantId;

  /// The rally ID.
  final String rallyId;

  /// The rally name.
  final String rallyName;

  /// Optional description of the rally.
  final String? description;

  /// Optional cover image URL for the rally.
  final String? coverImageUrl;

  /// When the rally starts.
  final DateTime? startDate;

  /// When the rally ends.
  final DateTime? endDate;

  /// Number of joined members in the rally.
  final int memberCount;

  /// The role offered in this invitation.
  final ParticipantRole role;

  /// Info about who sent the invite.
  final PendingInvitationInviter? invitedBy;

  /// When the invitation was created.
  final DateTime? invitedAt;

  /// Creates a new [PendingInvitationItem].
  const PendingInvitationItem({
    required this.participantId,
    required this.rallyId,
    required this.rallyName,
    this.description,
    this.coverImageUrl,
    this.startDate,
    this.endDate,
    this.memberCount = 0,
    required this.role,
    this.invitedBy,
    this.invitedAt,
  });

  /// Creates a [PendingInvitationItem] from a JSON map.
  factory PendingInvitationItem.fromJson(Map<String, dynamic> json) {
    return PendingInvitationItem(
      participantId: json['participantId'] as String? ?? '',
      rallyId: json['rallyId'] as String? ?? '',
      rallyName: json['rallyName'] as String? ?? '',
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      memberCount: json['memberCount'] as int? ?? 0,
      role: ParticipantRole.fromString(json['role'] as String? ?? 'participant'),
      invitedBy: json['invitedBy'] != null
          ? PendingInvitationInviter.fromJson(json['invitedBy'] as Map<String, dynamic>)
          : null,
      invitedAt: json['invitedAt'] != null ? DateTime.tryParse(json['invitedAt'] as String) : null,
    );
  }
}

/// Basic info about the user who sent an invitation.
class PendingInvitationInviter {
  /// The inviter's user ID.
  final String id;

  /// The inviter's username.
  final String username;

  /// The inviter's first name.
  final String? firstName;

  /// The inviter's last name.
  final String? lastName;

  /// The inviter's avatar URL.
  final String? avatarUrl;

  /// Creates a new [PendingInvitationInviter].
  const PendingInvitationInviter({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  /// Creates a [PendingInvitationInviter] from a JSON map.
  factory PendingInvitationInviter.fromJson(Map<String, dynamic> json) {
    return PendingInvitationInviter(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Display name (first + last, or @username).
  String get displayName {
    final String full = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return full.isNotEmpty ? full : '@$username';
  }
}

/// Response for `GET /api/v1/user/me/invitations`.
class PendingInvitationsResponse {
  /// The list of pending invitations.
  final List<PendingInvitationItem> invitations;

  /// Total count of pending invitations.
  final int total;

  /// Creates a new [PendingInvitationsResponse].
  const PendingInvitationsResponse({
    required this.invitations,
    required this.total,
  });

  /// Creates a [PendingInvitationsResponse] from a JSON map.
  factory PendingInvitationsResponse.fromJson(Map<String, dynamic> json) {
    return PendingInvitationsResponse(
      invitations: (json['invitations'] as List<dynamic>?)
              ?.map((dynamic e) => PendingInvitationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <PendingInvitationItem>[],
      total: json['total'] as int? ?? 0,
    );
  }
}
