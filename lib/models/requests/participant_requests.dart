/// Request models for Rally Participant API endpoints.
library;

import 'package:rally/models/enums.dart';

class InviteParticipantRequest {
  /// The user ID to invite.
  final String userId;

  /// The role to assign (owner, editor, participant).
  final ParticipantRole? role;

  /// Creates a new [InviteParticipantRequest].
  const InviteParticipantRequest({required this.userId, this.role});

  /// Converts this request to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'userId': userId, if (role != null) 'role': role!.name};
  }
}

/// Request model for updating a participant's role or status.
///
/// Used by `PUT /api/v1/rallies/{id}/participants/{participantId}`.
class UpdateParticipantRequest {
  /// Updated role (owner, editor, participant).
  final ParticipantRole? role;

  /// Updated status (invited, joined).
  final ParticipationStatus? status;

  /// Creates a new [UpdateParticipantRequest].
  const UpdateParticipantRequest({this.role, this.status});

  /// Converts this request to a JSON map.
  /// Only includes non-null fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (role != null) 'role': role!.name,
      if (status != null) 'status': status!.name,
    };
  }
}
