/// Request models for Activity API endpoints.
library;

/// Request model for creating a new activity.
///
/// Used by `POST /api/v1/events/{id}/activities`.
class CreateActivityRequest {
  /// The activity name (required).
  final String name;

  /// Description of the activity.
  final String? description;

  /// Optional notes about this activity.
  final String? notes;

  /// Google Places API place ID.
  final String? googlePlaceId;

  /// Latitude coordinate.
  final double? lat;

  /// Longitude coordinate.
  final double? lng;

  /// Order of the activity within the event.
  final int? activityOrder;

  /// When the activity starts (ISO 8601 format).
  final String? startTime;

  /// When the activity ends (ISO 8601 format).
  final String? endTime;

  /// Creates a new [CreateActivityRequest].
  const CreateActivityRequest({
    required this.name,
    this.description,
    this.notes,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.activityOrder,
    this.startTime,
    this.endTime,
  });

  /// Converts this request to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (activityOrder != null) 'activityOrder': activityOrder,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}

/// Request model for updating an existing activity.
///
/// Used by `PUT /api/v1/activities/{id}`.
class UpdateActivityRequest {
  /// Updated activity name.
  final String? name;

  /// Updated description.
  final String? description;

  /// Updated notes.
  final String? notes;

  /// Updated Google Place ID.
  final String? googlePlaceId;

  /// Updated latitude.
  final double? lat;

  /// Updated longitude.
  final double? lng;

  /// Updated activity order.
  final int? activityOrder;

  /// Updated status (planned, completed, etc.).
  final String? status;

  /// Updated start time (ISO 8601 format).
  final String? startTime;

  /// Updated end time (ISO 8601 format).
  final String? endTime;

  /// Creates a new [UpdateActivityRequest].
  const UpdateActivityRequest({
    this.name,
    this.description,
    this.notes,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.activityOrder,
    this.status,
    this.startTime,
    this.endTime,
  });

  /// Converts this request to a JSON map.
  /// Only includes non-null fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (activityOrder != null) 'activityOrder': activityOrder,
      if (status != null) 'status': status,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}
