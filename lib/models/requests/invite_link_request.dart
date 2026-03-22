/// Request model for creating an invite link token.
///
/// Used by `POST /api/v1/rallies/{id}/invite-links`.
class CreateInviteLinkRequest {
  /// The role to grant when the link is used.
  ///
  /// Defaults to `"participant"` on the backend if omitted.
  final String? role;

  /// Number of days before the link expires.
  final int? expiresInDays;

  /// Maximum number of times the link can be used.
  final int? maxUses;

  /// Creates a new [CreateInviteLinkRequest].
  const CreateInviteLinkRequest({this.role, this.expiresInDays, this.maxUses});

  /// Converts this request to a JSON map.
  ///
  /// Only includes non-null fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (role != null) 'role': role,
      if (expiresInDays != null) 'expiresInDays': expiresInDays,
      if (maxUses != null) 'maxUses': maxUses,
    };
  }
}
