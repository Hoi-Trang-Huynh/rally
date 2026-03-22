/// Response models for the join-via-link and invite preview endpoints.
library;

/// Basic info of the user who owns the rally
class InvitePreviewOwner {
  /// User's avatar URL
  final String? avatarUrl;

  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// User's username
  final String username;

  /// Creates a new [InvitePreviewOwner].
  const InvitePreviewOwner({
    this.avatarUrl,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  /// Creates an [InvitePreviewOwner] from a JSON map.
  factory InvitePreviewOwner.fromJson(Map<String, dynamic> json) {
    return InvitePreviewOwner(
      avatarUrl: json['avatarUrl'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );
  }
}

/// Preview information returned when validating an invite token.
///
/// Returned by `GET /api/v1/rallies/invite-links/{token}/preview`.
/// This endpoint allows the user to see rally details before committing
/// to join.
class InvitePreviewResponse {
  /// Optional cover image URL for the rally.
  final String? coverImageUrl;

  /// Description of the rally.
  final String? description;

  /// When the rally ends.
  final DateTime? endDate;

  /// Number of events in the rally.
  final int eventCount;

  /// The time the user was invited.
  final DateTime? invitedAt;

  /// Current number of members in the rally.
  final int memberCount;

  /// Owner of the rally.
  final InvitePreviewOwner owner;

  /// ID of the participant record (if user was already invited/joined).
  final String participantId;

  /// The user's current participation status (empty if no existing record).
  final String participantStatus;

  /// ID of the rally.
  final String rallyId;

  /// Name of the rally.
  final String rallyName;

  /// Role offered in the invitation.
  final String roleOffered;

  /// When the rally starts.
  final DateTime? startDate;

  /// Status of the rally.
  final String status;

  /// Creates a new [InvitePreviewResponse].
  const InvitePreviewResponse({
    this.coverImageUrl,
    this.description,
    this.endDate,
    required this.eventCount,
    this.invitedAt,
    required this.memberCount,
    required this.owner,
    required this.participantId,
    this.participantStatus = '',
    required this.rallyId,
    required this.rallyName,
    required this.roleOffered,
    this.startDate,
    required this.status,
  });

  /// Creates an [InvitePreviewResponse] from a JSON map.
  factory InvitePreviewResponse.fromJson(Map<String, dynamic> json) {
    return InvitePreviewResponse(
      coverImageUrl: json['coverImageUrl'] as String?,
      description: json['description'] as String?,
      endDate:
          json['endDate'] != null
              ? DateTime.tryParse(json['endDate'] as String)
              : null,
      eventCount: json['eventCount'] as int? ?? 0,
      invitedAt:
          json['invitedAt'] != null
              ? DateTime.tryParse(json['invitedAt'] as String)
              : null,
      memberCount: json['memberCount'] as int? ?? 0,
      owner:
          json['owner'] != null
              ? InvitePreviewOwner.fromJson(
                json['owner'] as Map<String, dynamic>,
              )
              : const InvitePreviewOwner(
                firstName: '',
                lastName: '',
                username: '',
              ),
      participantId: json['participantId'] as String? ?? '',
      participantStatus: json['participantStatus'] as String? ?? '',
      rallyId: json['rallyId'] as String? ?? '',
      rallyName: json['rallyName'] as String? ?? '',
      roleOffered: json['roleOffered'] as String? ?? 'participant',
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'] as String)
              : null,
      status: json['status'] as String? ?? '',
    );
  }
}

/// Response returned after calling `POST /api/v1/rallies/join-via-link`.
class JoinViaLinkResponse {
  /// Whether the request succeeded.
  final bool success;

  /// Human-readable message from the backend.
  final String message;

  /// The ID of the rally the user was added to.
  final String rallyId;

  /// The role granted to the user.
  final String role;

  /// The current status of the user (e.g., 'invited', 'joined').
  final String status;

  /// Creates a new [JoinViaLinkResponse].
  const JoinViaLinkResponse({
    required this.success,
    required this.message,
    required this.rallyId,
    required this.role,
    required this.status,
  });

  /// Creates a [JoinViaLinkResponse] from a JSON map.
  factory JoinViaLinkResponse.fromJson(Map<String, dynamic> json) {
    return JoinViaLinkResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      rallyId: json['rallyId'] as String? ?? '',
      role: json['role'] as String? ?? 'participant',
      status: json['status'] as String? ?? 'invited',
    );
  }
}
