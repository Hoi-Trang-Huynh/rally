import 'package:rally/models/place_result.dart';
import 'package:rally/services/api_client.dart';

/// Repository for the backend saved-places endpoints.
class SavedPlacesRepository {
  /// Creates a [SavedPlacesRepository].
  SavedPlacesRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Returns all places bookmarked by the authenticated user.
  Future<List<PlaceResult>> getSavedPlaces() async {
    final dynamic response = await _apiClient.get('/api/v1/saved-places');
    final List<dynamic> places =
        (response as Map<String, dynamic>)['places'] as List<dynamic>;
    return places
        .map(
          (dynamic json) =>
              PlaceResult.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Bookmarks [placeId]; the backend fetches and stores the place snapshot.
  Future<void> savePlace(String placeId) async {
    await _apiClient.post(
      '/api/v1/saved-places',
      body: <String, String>{'placeId': placeId},
    );
  }

  /// Removes the bookmark for [placeId].
  Future<void> removePlace(String placeId) async {
    await _apiClient.delete('/api/v1/saved-places/$placeId');
  }
}
