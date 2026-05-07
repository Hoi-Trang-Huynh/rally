import 'package:rally/models/place_result.dart';
import 'package:rally/services/api_client.dart';

/// Repository for the backend Google Places proxy endpoints.
class PlacesRepository {
  /// Creates a [PlacesRepository].
  PlacesRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Returns places near [lat]/[lng] of the given Google Places [type].
  Future<List<PlaceResult>> nearbySearch(
    double lat,
    double lng,
    String type, {
    int maxCount = 10,
  }) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/places/nearby',
      queryParams: <String, String>{
        'lat': lat.toString(),
        'lng': lng.toString(),
        'type': type,
        'maxCount': maxCount.toString(),
      },
    );
    final List<dynamic> places =
        (response as Map<String, dynamic>)['places'] as List<dynamic>;
    return places
        .map((dynamic json) => PlaceResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns places matching [query] near [lat]/[lng].
  Future<List<PlaceResult>> searchPlaces(
    double lat,
    double lng,
    String query, {
    int maxCount = 10,
  }) async {
    final dynamic response = await _apiClient.get(
      '/api/v1/places/search',
      queryParams: <String, String>{
        'q': query,
        'lat': lat.toString(),
        'lng': lng.toString(),
        'maxCount': maxCount.toString(),
      },
    );
    final List<dynamic> places =
        (response as Map<String, dynamic>)['places'] as List<dynamic>;
    return places
        .map((dynamic json) => PlaceResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Returns full details for a single place by its Google Place ID.
  Future<PlaceResult> getPlaceDetails(String placeId) async {
    final dynamic response = await _apiClient.get('/api/v1/places/$placeId');
    return PlaceResult.fromJson(response as Map<String, dynamic>);
  }
}
