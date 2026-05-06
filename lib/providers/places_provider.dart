import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/place_result.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/places_repository.dart';

/// Provider for [PlacesRepository].
final Provider<PlacesRepository> placesRepositoryProvider =
    Provider<PlacesRepository>((Ref ref) {
  return PlacesRepository(ref.watch(apiClientProvider));
});

/// Parameters for [nearbyPlacesProvider]. Requires value equality for Riverpod family caching.
class NearbySearchParams {
  /// Creates [NearbySearchParams].
  const NearbySearchParams({
    required this.lat,
    required this.lng,
    required this.type,
  });

  /// Latitude of the search centre.
  final double lat;

  /// Longitude of the search centre.
  final double lng;

  /// Google Places type (e.g. "restaurant", "lodging").
  final String type;

  @override
  bool operator ==(Object other) =>
      other is NearbySearchParams &&
      other.lat == lat &&
      other.lng == lng &&
      other.type == type;

  @override
  int get hashCode => Object.hash(lat, lng, type);
}

/// Fetches nearby places for the given [NearbySearchParams].
///
/// Auto-disposed and keyed by params so each section caches independently.
final AutoDisposeFutureProviderFamily<List<PlaceResult>, NearbySearchParams>
    nearbyPlacesProvider = FutureProvider.autoDispose
        .family<List<PlaceResult>, NearbySearchParams>(
  (Ref ref, NearbySearchParams params) {
    return ref
        .watch(placesRepositoryProvider)
        .nearbySearch(params.lat, params.lng, params.type);
  },
);

/// Fetches full details for a single place by its Google Place ID.
final AutoDisposeFutureProviderFamily<PlaceResult, String> placeDetailsProvider =
    FutureProvider.autoDispose.family<PlaceResult, String>(
  (Ref ref, String placeId) {
    return ref.watch(placesRepositoryProvider).getPlaceDetails(placeId);
  },
);

/// Holds the place selected via a map marker tap.
///
/// Written by [_DiscoveryScreenState] on marker tap; consumed (and cleared)
/// by [_ExploreBottomSheetState] via [ref.listen].
final StateProvider<PlaceResult?> markerSelectedPlaceProvider =
    StateProvider<PlaceResult?>((Ref _) => null);
