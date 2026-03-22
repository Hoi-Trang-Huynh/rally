import 'package:rally/models/enums.dart';
import 'package:rally/models/responses/rally_response.dart';

/// Response model for the GET rally endpoint.
///
/// Returned by `GET /api/v1/rallies/{id}`. Extends [RallyResponse] with the
/// current user's role and participation status in the rally.
class RallyJoinResponse extends RallyResponse {
  /// The current user's role in this rally.
  final ParticipantRole currentUserRole;

  /// The current user's participation status in this rally.
  final ParticipationStatus currentUserStatus;

  /// Creates a new [RallyJoinResponse].
  const RallyJoinResponse({
    required super.id,
    required super.name,
    super.description,
    super.coverImageUrl,
    required super.ownerId,
    super.status,
    super.startDate,
    super.endDate,
    super.createdAt,
    super.updatedAt,
    required this.currentUserRole,
    required this.currentUserStatus,
  });

  /// Creates a [RallyJoinResponse] from a JSON map.
  factory RallyJoinResponse.fromJson(Map<String, dynamic> json) {
    return RallyJoinResponse(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      status: RallyStatus.fromString(json['status'] as String? ?? 'draft'),
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      currentUserRole: ParticipantRole.fromString(json['currentUserRole'] as String? ?? 'participant'),
      currentUserStatus: ParticipationStatus.fromString(json['currentUserStatus'] as String? ?? 'invited'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'currentUserRole': currentUserRole.name,
      'currentUserStatus': currentUserStatus.name,
    };
  }

  @override
  String toString() {
    return 'RallyJoinResponse(id: $id, name: $name, role: ${currentUserRole.name}, status: ${currentUserStatus.name})';
  }
}
