import 'package:rally/models/requests/activity_requests.dart';
import 'package:rally/models/requests/event_requests.dart';
import 'package:rally/models/requests/participant_requests.dart';
import 'package:rally/models/requests/rally_requests.dart';
import 'package:rally/models/responses/activity_response.dart';
import 'package:rally/models/responses/event_response.dart';
import 'package:rally/models/responses/rally_participant_response.dart';
import 'package:rally/models/responses/rally_response.dart';
import 'package:rally/services/api_client.dart';

/// Repository for rally-related API calls.
///
/// Handles communication with the backend for rally, event, activity,
/// and participant data.
class RallyRepository {
  final ApiClient _apiClient;

  /// Creates a new [RallyRepository].
  RallyRepository(this._apiClient);

  // ============================================
  // Rally Operations
  // ============================================

  /// Creates a new rally.
  ///
  /// The authenticated user becomes the owner of the rally.
  /// Returns a [RallyResponse] containing the created rally data.
  Future<RallyResponse> createRally(CreateRallyRequest request) async {
    final dynamic response = await _apiClient.post('/api/v1/rallies', body: request.toJson());
    return RallyResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Updates an existing rally.
  ///
  /// [id] The ID of the rally to update.
  /// [request] The update payload.
  /// Requires owner or editor role.
  /// Returns a [RallyResponse] containing the updated rally data.
  Future<RallyResponse> updateRally(String id, UpdateRallyRequest request) async {
    final dynamic response = await _apiClient.put('/api/v1/rallies/$id', body: request.toJson());
    return RallyResponse.fromJson(response as Map<String, dynamic>);
  }

  // ============================================
  // Event Operations
  // ============================================

  /// Creates a new event within a rally.
  ///
  /// [rallyId] The ID of the parent rally.
  /// [request] The event creation payload.
  /// Requires owner or editor role in the rally.
  /// Returns an [EventResponse] containing the created event data.
  Future<EventResponse> createEvent(String rallyId, CreateEventRequest request) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/rallies/$rallyId/events',
      body: request.toJson(),
    );
    return EventResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Updates an existing event.
  ///
  /// [id] The ID of the event to update.
  /// [request] The update payload.
  /// Requires owner or editor role in the event's rally.
  /// Returns an [EventResponse] containing the updated event data.
  Future<EventResponse> updateEvent(String id, UpdateEventRequest request) async {
    final dynamic response = await _apiClient.put('/api/v1/events/$id', body: request.toJson());
    return EventResponse.fromJson(response as Map<String, dynamic>);
  }

  // ============================================
  // Activity Operations
  // ============================================

  /// Creates a new activity within an event.
  ///
  /// [eventId] The ID of the parent event.
  /// [request] The activity creation payload.
  /// Requires owner or editor role in the activity's rally.
  /// Returns an [ActivityResponse] containing the created activity data.
  Future<ActivityResponse> createActivity(String eventId, CreateActivityRequest request) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/events/$eventId/activities',
      body: request.toJson(),
    );
    return ActivityResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Updates an existing activity.
  ///
  /// [id] The ID of the activity to update.
  /// [request] The update payload.
  /// Requires owner or editor role in the activity's rally.
  /// Returns an [ActivityResponse] containing the updated activity data.
  Future<ActivityResponse> updateActivity(String id, UpdateActivityRequest request) async {
    final dynamic response = await _apiClient.put('/api/v1/activities/$id', body: request.toJson());
    return ActivityResponse.fromJson(response as Map<String, dynamic>);
  }

  // ============================================
  // Participant Operations
  // ============================================

  /// Invites a user to join a rally.
  ///
  /// [rallyId] The ID of the rally.
  /// [request] The invite payload containing user ID and optional role.
  /// Requires owner or editor role.
  /// Returns a [RallyParticipantResponse] containing the participant data.
  Future<RallyParticipantResponse> inviteParticipant(
    String rallyId,
    InviteParticipantRequest request,
  ) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/rallies/$rallyId/participants',
      body: request.toJson(),
    );
    return RallyParticipantResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Updates a participant's role or status.
  ///
  /// [rallyId] The ID of the rally.
  /// [participantId] The ID of the participant to update.
  /// [request] The update payload.
  /// Role changes require owner. Status changes allowed for self.
  /// Returns a [RallyParticipantResponse] containing the updated participant data.
  Future<RallyParticipantResponse> updateParticipant(
    String rallyId,
    String participantId,
    UpdateParticipantRequest request,
  ) async {
    final dynamic response = await _apiClient.put(
      '/api/v1/rallies/$rallyId/participants/$participantId',
      body: request.toJson(),
    );
    return RallyParticipantResponse.fromJson(response as Map<String, dynamic>);
  }
}
