/// Response model for rally participant endpoints.
///
/// Returned by `POST /api/v1/rallies/{id}/participants`
/// and `PUT /api/v1/rallies/{id}/participants/{participantId}`.
class RallyParticipantResponse {
  /// The MongoDB document ID.
  final String id;

  /// The rally ID this participant belongs to.
  final String rallyId;

  /// The user ID of the participant.
  final String userId;

  /// The participant's role (owner, editor, participant).
  final String role;

  /// The participant's status (invited, joined).
  final String status;

  /// The user ID of who invited this participant.
  final String? invitedBy;

  /// When the participant was invited.
  final DateTime? invitedAt;

  /// When the participant joined.
  final DateTime? joinedAt;

  /// Creates a new [RallyParticipantResponse].
  const RallyParticipantResponse({
    required this.id,
    required this.rallyId,
    required this.userId,
    this.role = 'participant',
    this.status = 'invited',
    this.invitedBy,
    this.invitedAt,
    this.joinedAt,
  });

  /// Creates a [RallyParticipantResponse] from a JSON map.
  factory RallyParticipantResponse.fromJson(Map<String, dynamic> json) {
    return RallyParticipantResponse(
      id: json['id'] as String? ?? '',
      rallyId: json['rallyId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? 'participant',
      status: json['status'] as String? ?? 'invited',
      invitedBy: json['invitedBy'] as String?,
      invitedAt: json['invitedAt'] != null ? DateTime.tryParse(json['invitedAt'] as String) : null,
      joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'] as String) : null,
    );
  }

  /// Converts this [RallyParticipantResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'rallyId': rallyId,
      'userId': userId,
      'role': role,
      'status': status,
      'invitedBy': invitedBy,
      'invitedAt': invitedAt?.toIso8601String(),
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RallyParticipantResponse(id: $id, userId: $userId, role: $role, status: $status)';
  }
}
