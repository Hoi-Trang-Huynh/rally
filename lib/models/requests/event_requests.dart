/// Request models for Event API endpoints.
library;

/// Request model for creating a new event.
///
/// Used by `POST /api/v1/rallies/{id}/events`.
class CreateEventRequest {
  /// The event/location name (required).
  final String name;

  /// Optional notes about this event.
  final String? notes;

  /// Google Places API place ID.
  final String? googlePlaceId;

  /// Latitude coordinate.
  final double? lat;

  /// Longitude coordinate.
  final double? lng;

  /// Order of visit within the rally.
  final int? visitOrder;

  /// When the event starts (ISO 8601 format).
  final String? startTime;

  /// When the event ends (ISO 8601 format).
  final String? endTime;

  /// Creates a new [CreateEventRequest].
  const CreateEventRequest({
    required this.name,
    this.notes,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.visitOrder,
    this.startTime,
    this.endTime,
  });

  /// Converts this request to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      if (notes != null) 'notes': notes,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (visitOrder != null) 'visitOrder': visitOrder,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}

/// Request model for updating an existing event.
///
/// Used by `PUT /api/v1/events/{id}`.
class UpdateEventRequest {
  /// Updated event name.
  final String? name;

  /// Updated notes.
  final String? notes;

  /// Updated Google Place ID.
  final String? googlePlaceId;

  /// Updated latitude.
  final double? lat;

  /// Updated longitude.
  final double? lng;

  /// Updated visit order.
  final int? visitOrder;

  /// Updated start time (ISO 8601 format).
  final String? startTime;

  /// Updated end time (ISO 8601 format).
  final String? endTime;

  /// Creates a new [UpdateEventRequest].
  const UpdateEventRequest({
    this.name,
    this.notes,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.visitOrder,
    this.startTime,
    this.endTime,
  });

  /// Converts this request to a JSON map.
  /// Only includes non-null fields.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (googlePlaceId != null) 'googlePlaceId': googlePlaceId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (visitOrder != null) 'visitOrder': visitOrder,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}
