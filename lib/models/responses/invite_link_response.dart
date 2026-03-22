/// Response models for invite link API endpoints.
library;

/// A single invite link item returned by the backend.
class InviteLinkItem {
  /// The unique token for this invite link.
  final String token;

  /// The role granted when this link is used.
  final String role;

  /// When this link expires, or `null` if it never expires.
  final DateTime? expiresAt;

  /// Maximum number of uses allowed, or `null` for unlimited.
  final int? maxUses;

  /// Number of times this link has been used so far.
  final int currentUses;

  /// Whether this link is still active.
  final bool isActive;

  /// When this link was created.
  final DateTime createdAt;

  /// Creates a new [InviteLinkItem].
  const InviteLinkItem({
    required this.token,
    required this.role,
    required this.currentUses,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
    this.maxUses,
  });

  /// Creates an [InviteLinkItem] from a JSON map.
  ///
  /// Handles both camelCase (backend default) and snake_case key formats.
  factory InviteLinkItem.fromJson(Map<String, dynamic> json) {
    return InviteLinkItem(
      token: json['token'] as String,
      role:
          json['roleToGrant'] as String? ??
          json['role_to_grant'] as String? ??
          json['role'] as String? ??
          'participant',
      expiresAt: _parseDateTime(json['expiresAt'] ?? json['expires_at']),
      maxUses: json['maxUses'] as int? ?? json['max_uses'] as int?,
      currentUses: json['currentUses'] as int? ?? json['current_uses'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
    );
  }

  /// Parses a nullable dynamic value to [DateTime].
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.parse(value as String);
  }

  /// Whether this link has expired based on [expiresAt].
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Whether this link has reached its max usage limit.
  bool get isMaxedOut => maxUses != null && currentUses >= maxUses!;
}

/// Response wrapper for a list of invite links.
///
/// Parses the array returned by `GET /api/v1/rallies/{id}/invite-links`.
class InviteLinkListResponse {
  /// The list of invite link items.
  final List<InviteLinkItem> links;

  /// Creates a new [InviteLinkListResponse].
  const InviteLinkListResponse({required this.links});

  /// Creates an [InviteLinkListResponse] from a JSON list.
  ///
  /// Handles both direct array response and an object with a `links`/`data` key.
  factory InviteLinkListResponse.fromJson(dynamic json) {
    if (json is List) {
      return InviteLinkListResponse(
        links:
            json
                .map((dynamic item) => InviteLinkItem.fromJson(item as Map<String, dynamic>))
                .toList(),
      );
    }

    final Map<String, dynamic> map = json as Map<String, dynamic>;
    final List<dynamic> items =
        (map['links'] as List<dynamic>?) ?? (map['data'] as List<dynamic>?) ?? <dynamic>[];

    return InviteLinkListResponse(
      links:
          items
              .map((dynamic item) => InviteLinkItem.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }
}
