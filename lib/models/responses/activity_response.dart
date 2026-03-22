/// Response model for activity endpoints.
///
/// Returned by `POST /api/v1/events/{id}/activities` and `PUT /api/v1/activities/{id}`.
class ActivityResponse {
  /// The MongoDB document ID.
  final String id;

  /// The parent event's ID.
  final String eventId;

  /// The activity name.
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
  final int activityOrder;

  /// Status of the activity (planned, completed, etc.).
  final String status;

  /// When the activity starts.
  final DateTime? startTime;

  /// When the activity ends.
  final DateTime? endTime;

  /// When the activity was created.
  final DateTime? createdAt;

  /// When the activity was last updated.
  final DateTime? updatedAt;

  /// Creates a new [ActivityResponse].
  const ActivityResponse({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    this.notes,
    this.googlePlaceId,
    this.lat,
    this.lng,
    this.activityOrder = 0,
    this.status = 'planned',
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates an [ActivityResponse] from a JSON map.
  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      googlePlaceId: json['googlePlaceId'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      activityOrder: json['activityOrder'] as int? ?? 0,
      status: json['status'] as String? ?? 'planned',
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  /// Converts this [ActivityResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'notes': notes,
      'googlePlaceId': googlePlaceId,
      'lat': lat,
      'lng': lng,
      'activityOrder': activityOrder,
      'status': status,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ActivityResponse(id: $id, eventId: $eventId, name: $name, status: $status)';
  }
}
