import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/place_result.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/saved_places_repository.dart';

/// Provider for [SavedPlacesRepository].
final Provider<SavedPlacesRepository> savedPlacesRepositoryProvider =
    Provider<SavedPlacesRepository>((Ref ref) {
  return SavedPlacesRepository(ref.watch(apiClientProvider));
});

/// Manages the list of places bookmarked by the authenticated user.
///
/// Exposes [save], [remove], and [isSaved] for mutation and membership checks.
class SavedPlacesNotifier extends AsyncNotifier<List<PlaceResult>> {
  @override
  FutureOr<List<PlaceResult>> build() {
    return ref.watch(savedPlacesRepositoryProvider).getSavedPlaces();
  }

  /// Returns true if [placeId] is in the current saved list.
  bool isSaved(String placeId) =>
      state.valueOrNull?.any((PlaceResult p) => p.id == placeId) ?? false;

  /// Bookmarks [placeId] and refreshes the list.
  Future<void> save(String placeId) async {
    await ref.read(savedPlacesRepositoryProvider).savePlace(placeId);
    ref.invalidateSelf();
  }

  /// Removes the bookmark for [placeId] and refreshes the list.
  Future<void> remove(String placeId) async {
    await ref.read(savedPlacesRepositoryProvider).removePlace(placeId);
    ref.invalidateSelf();
  }
}

/// Global provider for the user's saved places.
final AsyncNotifierProvider<SavedPlacesNotifier, List<PlaceResult>>
    savedPlacesProvider =
    AsyncNotifierProvider<SavedPlacesNotifier, List<PlaceResult>>(
  SavedPlacesNotifier.new,
);
