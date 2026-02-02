/// Response model for rally endpoints.
///
/// Returned by `POST /api/v1/rallies` and `PUT /api/v1/rallies/{id}`.
class RallyResponse {
  /// The MongoDB document ID.
  final String id;

  /// The rally name.
  final String name;

  /// Optional description of the rally.
  final String? description;

  /// URL of the cover image.
  final String? coverImageUrl;

  /// The user ID of the rally owner.
  final String ownerId;

  /// Status of the rally (draft, active, completed, etc.).
  final String status;

  /// When the rally starts.
  final DateTime? startDate;

  /// When the rally ends.
  final DateTime? endDate;

  /// When the rally was created.
  final DateTime? createdAt;

  /// When the rally was last updated.
  final DateTime? updatedAt;

  /// Creates a new [RallyResponse].
  const RallyResponse({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.ownerId,
    this.status = 'draft',
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [RallyResponse] from a JSON map.
  factory RallyResponse.fromJson(Map<String, dynamic> json) {
    return RallyResponse(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      ownerId: json['ownerId'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  /// Converts this [RallyResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'ownerId': ownerId,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RallyResponse(id: $id, name: $name, status: $status)';
  }
}
