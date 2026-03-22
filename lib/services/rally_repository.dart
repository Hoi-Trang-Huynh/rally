import 'package:rally/models/enums.dart';
import 'package:rally/models/requests/activity_requests.dart';
import 'package:rally/models/requests/event_requests.dart';
import 'package:rally/models/requests/invite_link_request.dart';
import 'package:rally/models/requests/participant_requests.dart';
import 'package:rally/models/requests/rally_requests.dart';
import 'package:rally/models/responses/activity_response.dart';
import 'package:rally/models/responses/event_response.dart';
import 'package:rally/models/responses/rally_join_response.dart';
import 'package:rally/models/responses/friend_list_response.dart';
import 'package:rally/models/responses/invite_link_response.dart';
import 'package:rally/models/responses/join_via_link_response.dart';
import 'package:rally/models/responses/participant_list_response.dart';
import 'package:rally/models/responses/rally_participant_response.dart';
import 'package:rally/models/responses/rally_response.dart';
import 'package:rally/services/api_client.dart';
import 'package:rally/utils/validation_constants.dart';

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

  /// Fetches a single rally by ID.
  ///
  /// [id] The ID of the rally to fetch.
  /// Returns a [RallyJoinResponse] containing full rally data plus the
  /// current user's role and participation status.
  ///
  /// TODO: Replace with streaming/WebSocket listener for real-time updates.
  Future<RallyJoinResponse> getRally(String id) async {
    final dynamic response = await _apiClient.get('/api/v1/rallies/$id');
    return RallyJoinResponse.fromJson(response as Map<String, dynamic>);
  }

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

  /// Gets a paginated list of participants for a rally.
  ///
  /// [rallyId] The ID of the rally.
  /// [page] The page number to fetch.
  /// [pageSize] The number of items per page.
  /// [role] Optional role to filter by.
  /// Returns a [ParticipantListResponse] containing the participants data.
  Future<ParticipantListResponse> getParticipants(
    String rallyId, {
    int page = 1,
    int pageSize = PaginationDefaults.defaultPageSize,
    ParticipantRole? role,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (role != null) {
      queryParams['role'] = role.name;
    }

    final dynamic response = await _apiClient.get(
      '/api/v1/rallies/$rallyId/participants',
      queryParams: queryParams,
    );
    return ParticipantListResponse.fromJson(response as Map<String, dynamic>);
  }

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

  /// Gets a paginated list of friends who can be invited to a rally.
  ///
  /// Returns only friends who are **not** already participants
  /// (any status: invited, joined, etc.) of the specified rally.
  ///
  /// [rallyId] The ID of the rally.
  /// [query] Optional search query to filter by name or username.
  /// [page] The page number (default: 1).
  /// [pageSize] The number of results per page.
  /// Returns a [FriendListResponse] containing the invitable friends list.
  Future<FriendListResponse> getInvitableFriends(
    String rallyId, {
    String? query,
    int page = 1,
    int pageSize = PaginationDefaults.invitableFriendsPageSize,
  }) async {
    final Map<String, String> queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final dynamic response = await _apiClient.get(
      '/api/v1/rallies/$rallyId/invitable-friends',
      queryParams: queryParams,
    );
    return FriendListResponse.fromJson(response as Map<String, dynamic>);
  }

  // ============================================
  // Invite Link Operations
  // ============================================

  /// Generates a new invite link token for a rally.
  ///
  /// [rallyId] The ID of the rally.
  /// [request] Optional configuration for role, expiry, and max uses.
  /// Requires owner or editor role.
  /// Returns an [InviteLinkItem] containing the created invite link data.
  Future<InviteLinkItem> createInviteLink(
    String rallyId, {
    CreateInviteLinkRequest? request,
  }) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/rallies/$rallyId/invite-links',
      body: request?.toJson(),
    );
    return InviteLinkItem.fromJson(response as Map<String, dynamic>);
  }

  /// Gets all active invite links for a rally.
  ///
  /// [rallyId] The ID of the rally.
  /// Requires owner or editor role.
  /// Returns an [InviteLinkListResponse] containing the list of invite links.
  Future<InviteLinkListResponse> getInviteLinks(String rallyId) async {
    final dynamic response = await _apiClient.get('/api/v1/rallies/$rallyId/invite-links');
    return InviteLinkListResponse.fromJson(response);
  }

  /// Revokes (deletes) an invite link token.
  ///
  /// [rallyId] The ID of the rally.
  /// [token] The token to revoke.
  /// Requires owner or editor role.
  Future<void> revokeInviteLink(String rallyId, String token) async {
    await _apiClient.delete('/api/v1/rallies/$rallyId/invite-links/$token');
  }

  // ============================================
  // Join Via Link Operations
  // ============================================

  /// Previews an invite link token without consuming it.
  ///
  /// Returns rally information so the user can decide whether to join.
  /// Endpoint: `GET /api/v1/rallies/invite-links/{token}/preview`
  Future<InvitePreviewResponse> getInvitePreview(String token) async {
    final dynamic response = await _apiClient.get('/api/v1/rallies/invite-links/$token/preview');
    return InvitePreviewResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Joins a rally using an invite link token.
  ///
  /// Endpoint: `POST /api/v1/rallies/join-via-link`
  /// Body: `{"token": "..."}`.
  /// The backend adds the user as a participant with `invited` status.
  Future<JoinViaLinkResponse> joinViaLink(String token) async {
    final dynamic response = await _apiClient.post(
      '/api/v1/rallies/join-via-link',
      body: <String, dynamic>{'token': token},
    );
    return JoinViaLinkResponse.fromJson(response as Map<String, dynamic>);
  }
}
