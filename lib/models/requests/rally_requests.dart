/// Request models for Rally API endpoints.
library;

/// Request model for creating a new rally.
///
/// Used by `POST /api/v1/rallies`.
class CreateRallyRequest {
  /// The rally name (required).
  final String name;

  /// Optional description of the rally.
  final String? description;

  /// URL of the cover image.
  final String? coverImageUrl;

  /// When the rally starts (ISO 8601 format).
  final String? startDate;

  /// When the rally ends (ISO 8601 format).
  final String? endDate;

  /// Creates a new [CreateRallyRequest].
  const CreateRallyRequest({
    required this.name,
    this.description,
    this.coverImageUrl,
    this.startDate,
    this.endDate,
  });

  /// Converts this request to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };
  }
}

/// Request model for updating an existing rally.
///
/// Used by `PUT /api/v1/rallies/{id}`.
class UpdateRallyRequest {
  /// Updated rally name.
  final String? name;

  /// Updated description.
  final String? description;

  /// Updated cover image URL.
  final String? coverImageUrl;

  /// Updated start date (ISO 8601 format).
  final String? startDate;

  /// Updated end date (ISO 8601 format).
  final String? endDate;

  /// Updated status (draft, active, completed, etc.).
  final String? status;

  /// Creates a new [UpdateRallyRequest].
  const UpdateRallyRequest({
    this.name,
    this.description,
    this.coverImageUrl,
    this.startDate,
    this.endDate,
    this.status,
  });

  /// Converts this request to a JSON map.
  /// Only includes non-null fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (status != null) 'status': status,
    };
  }
}
