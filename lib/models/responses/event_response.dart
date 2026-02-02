/// Response model for event endpoints.
///
/// Returned by `POST /api/v1/rallies/{id}/events` and `PUT /api/v1/events/{id}`.
class EventResponse {
  /// The MongoDB document ID.
  final String id;

  /// The parent rally's ID.
  final String rallyId;

  /// The event/location name.
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
  final int visitOrder;

  /// When the event starts.
  final DateTime? startTime;

  /// When the event ends.
  final DateTime? endTime;

  /// When the event was created.
  final DateTime? createdAt;

  /// When the event was last updated.
  final DateTime? updatedAt;

  /// Creates a new [EventResponse].
  const EventResponse({
    required this.id,
    required this.rallyId,
    required this.name,
    this.notes,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.visitOrder = 0,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates an [EventResponse] from a JSON map.
  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'] as String? ?? '',
      rallyId: json['rallyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      notes: json['notes'] as String?,
      googlePlaceId: json['googlePlaceId'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      visitOrder: json['visitOrder'] as int? ?? 0,
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  /// Converts this [EventResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'rallyId': rallyId,
      'name': name,
      'notes': notes,
      'googlePlaceId': googlePlaceId,
      'lat': lat,
      'lng': lng,
      'visitOrder': visitOrder,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'EventResponse(id: $id, rallyId: $rallyId, name: $name)';
  }
}
