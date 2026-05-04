# Explore Tab — Complete Implementation Plan

## Context
The Explore tab was scaffolded in RAL-298 with a Google Map + draggable bottom sheet. The current state is a polished UI prototype: all data is hardcoded mock, the bottom sheet renders 2-column grids instead of horizontal lists, card taps go nowhere, the category filter doesn't filter, GPS stub does nothing, and the Saved Places tab is empty. This plan closes every gap to match the design spec.

**User decisions:**
- Real nearby data → proxied through rally-backend (not direct Google API calls)
- Saved places → backend endpoint (syncs across devices)
- "Trending Places" section → remove it

---

## Phase 1 — Fix Layout: Horizontal Scrolling Lists

**Why first:** Most visible mismatch vs. design. No new dependencies. Unblocks visual review before touching data.

### Changes
- **Remove** `SliverGrid` rendering from `_buildHomeSlivers()` in `_ExploreBottomSheetState`
- **Replace** with a `SliverToBoxAdapter` wrapping a fixed-height `ListView.builder` (`scrollDirection: Axis.horizontal`) per section — each section gets its own horizontal scroll
- **New widget** `_ExploreHorizontalCard` — portrait card ~160w × full-height, same data fields as current `_ExploreGridCard` (image top 60%, name/rating/hours/distance below), bookmark overlay top-right
- **`_CollectionHorizontalCard`** — same horizontal format for Community Recommends
- **Remove** `showTrendingChip`, `_TrendingOnMapsChip`, and the entire `_kSections` `Trending Places` entry
- **Section order** (matching design):
  1. Community Recommends
  2. Where to Eat
  3. Where to Play
  4. Where to Drink ← add this section to mock data
  5. Where to Stay
- Drill-down vertical list (`_buildDrilldownSlivers`) stays as-is — already correct

### Files touched
- `lib/screens/discovery/discovery_screen.dart` — `_buildHomeSlivers`, card widgets, `_kSections`

---

## Phase 2 — Place Detail Screen

**Why second:** Every card tap, search result, and map marker tap needs somewhere to navigate. Nothing else is completable without it.

### New file: `lib/screens/discovery/place_detail_screen.dart`
- `ConsumerStatefulWidget` taking `String placeId` as constructor param
- Layout: `CustomScrollView` with `SliverAppBar` (hero image) + content slivers
- Content sections: name + rating row, address + hours, action buttons (Save, Get Directions, Add to Rally), description
- Loading state: multiple `ShimmerLoading` placeholders (same pattern as `UserProfileScreen`)
- Error state: `ErrorState(error: ..., onRetry: () => ref.invalidate(placeDetailsProvider(placeId)))`

### Router
- Add `static const String placePath = '/place/:placeId'` to `AppRoutes` class
- Add `static String place(String placeId) => '/place/$placeId'` helper
- Add `GoRoute(path: AppRoutes.placePath, builder: ...)` in `app_router.dart` outside the shell (full-screen, pushes onto stack — same as `userProfilePath`)

### Wire taps
- All `onTap: () => HapticFeedback.lightImpact()` in `_ExploreHorizontalCard` and `_ExploreListCard` → `context.push(AppRoutes.place(place.id))`
- Map `Marker` `onTap` → `context.push(AppRoutes.place(placeId))`

### Files touched
- `lib/screens/discovery/place_detail_screen.dart` ← new
- `lib/router/app_router.dart` — add `placePath` constant + `GoRoute`
- `lib/screens/discovery/discovery_screen.dart` — wire `onTap` in cards + markers

---

## Phase 3 — Backend Proxy: Places Nearby + Place Details

**Why third:** Replaces hardcoded mock with real data from your backend. Unlocks category filter and GPS.

> **Backend prerequisite:** rally-backend must expose these two endpoints before the frontend can use them:
> - `GET /api/v1/places/nearby?lat=&lng=&type=&maxCount=` → returns list of nearby places
> - `GET /api/v1/places/:placeId` → returns full place details
>
> The backend is responsible for holding the Google Places API key and proxying requests.

### New model: `lib/models/place_result.dart`
```dart
class PlaceResult {
  final String id;          // Google place ID
  final String name;
  final String? imageUrl;   // resolved photo URL (backend provides full URL)
  final double? rating;
  final int? reviewCount;
  final String? priceLevel; // e.g. "Free", "$", "$$", "$$$"
  final String? address;
  final String? hours;      // e.g. "Open 24h", "7AM–10PM"
  final bool? openNow;
  final double lat;
  final double lng;
  final String? type;       // e.g. "restaurant", "lodging"
}
```

### New service: `lib/services/places_repository.dart`
- Uses existing `ApiClient` (same auth, same base URL pattern)
- Methods:
  ```dart
  Future<List<PlaceResult>> nearbySearch(double lat, double lng, String type, {int maxCount = 10})
  Future<PlaceResult> getPlaceDetails(String placeId)
  ```
- Register as `placesRepositoryProvider` in `lib/providers/api_provider.dart`:
  ```dart
  final Provider<PlacesRepository> placesRepositoryProvider = Provider<PlacesRepository>((ref) {
    return PlacesRepository(ref.watch(apiClientProvider));
  });
  ```

### New providers: `lib/providers/places_provider.dart`
```dart
// Param class — needs == and hashCode for .family caching
class NearbySearchParams {
  final double lat;
  final double lng;
  final String type;
}

// Nearby places per section
final nearbyPlacesProvider =
    FutureProvider.autoDispose.family<List<PlaceResult>, NearbySearchParams>(...);

// Full detail for Place Detail Screen
final placeDetailsProvider =
    FutureProvider.autoDispose.family<PlaceResult, String>((ref, placeId) async {
      return ref.watch(placesRepositoryProvider).getPlaceDetails(placeId);
    });
```

### Wire into discovery screen
- `_ExploreBottomSheet` accepts `LatLng center` as a constructor parameter (passed from parent)
- Each section uses `ref.watch(nearbyPlacesProvider(NearbySearchParams(lat, lng, type)))` to populate its horizontal list
- Section → type mapping:
  | Section | `type` |
  |---|---|
  | Community Recommends | `tourist_attraction` |
  | Where to Eat | `restaurant` |
  | Where to Play | `amusement_park` |
  | Where to Drink | `bar` |
  | Where to Stay | `lodging` |
- Each section: `AsyncValue.when(data: buildHorizontalList, loading: shimmerRow, error: errorRow)`
- Remove all `_kSections` / `_kAllPlaces` hardcoded data

### Files touched
- `lib/models/place_result.dart` ← new
- `lib/services/places_repository.dart` ← new
- `lib/providers/places_provider.dart` ← new
- `lib/providers/api_provider.dart` — add `placesRepositoryProvider`
- `lib/screens/discovery/discovery_screen.dart` — replace hardcoded data, wire providers

---

## Phase 4 — GPS & "My Location"

**Why fourth:** Provides the `lat/lng` that Phase 3 `nearbySearch` needs as its center point.

### New package: add `geolocator: ^13.x` to `pubspec.yaml`
- Add `ACCESS_FINE_LOCATION` to `android/app/src/main/AndroidManifest.xml`
- Add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist`

### New provider: `lib/providers/location_provider.dart`
```dart
final currentLocationProvider = FutureProvider.autoDispose<LatLng?>((ref) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) return null;
  final Position pos = await Geolocator.getCurrentPosition();
  return LatLng(pos.latitude, pos.longitude);
});
```

### Wire into `_DiscoveryScreenState`
- Watch `currentLocationProvider`; on data → store in state as `LatLng? _userLocation`
- Fallback: use `_danangCenter` if null (permission denied or unavailable)
- Pass resolved `LatLng` to `_ExploreBottomSheet(center: _userLocation ?? _danangCenter)`
- Replace `_goToMyLocation()` stub:
  ```dart
  void _goToMyLocation() {
    HapticFeedback.lightImpact();
    final LatLng? loc = ref.read(currentLocationProvider).valueOrNull;
    if (loc != null) _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
  }
  ```

### Files touched
- `pubspec.yaml`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `lib/providers/location_provider.dart` ← new
- `lib/screens/discovery/discovery_screen.dart`

---

## Phase 5 — Category Filter Wiring

**Why fifth:** Needs Phases 3 and 4 so filtering actually changes real data, not a dead state field.

### Changes
- Map `_selectedCategoryIndex` to a section type string (or `null` for "All")
- When a chip is selected (not "All"):
  - Scroll the sheet's `CustomScrollView` to the matching section header using a `GlobalKey` per section + `Scrollable.ensureVisible`
  - Optionally animate the map camera to center on that section's loaded markers
- Update `CategoryFilterBar` chip labels to match section names:
  - All, Eat, Play, Drink, Stay (short labels), or match design exactly

### Files touched
- `lib/screens/discovery/widgets/category_filter_bar.dart`
- `lib/screens/discovery/discovery_screen.dart`

---

## Phase 6 — Saved Places (Backend)

**Why sixth:** Needs Phase 2 (detail screen) so places can be saved from somewhere meaningful.

> **Backend prerequisite:** rally-backend must expose:
> - `GET /api/v1/saved-places` → returns list of saved place IDs + basic metadata
> - `POST /api/v1/saved-places` body `{ placeId }` → saves a place
> - `DELETE /api/v1/saved-places/:placeId` → removes a saved place

### New service: `lib/services/saved_places_repository.dart`
```dart
class SavedPlacesRepository {
  Future<List<PlaceResult>> getSavedPlaces()
  Future<void> savePlace(String placeId)
  Future<void> removePlace(String placeId)
}
```
Register as `savedPlacesRepositoryProvider` in `api_provider.dart`.

### New provider: `lib/providers/saved_places_provider.dart`
```dart
class SavedPlacesNotifier extends AsyncNotifier<List<PlaceResult>> {
  Future<void> save(String placeId) async { ... ref.invalidateSelf(); }
  Future<void> remove(String placeId) async { ... ref.invalidateSelf(); }
  bool isSaved(String placeId) => state.valueOrNull?.any((p) => p.id == placeId) ?? false;
}

final savedPlacesProvider = AsyncNotifierProvider<SavedPlacesNotifier, List<PlaceResult>>(...);
```

### Wire into discovery screen
- Replace local `Set<String> _bookmarkedIds` with `ref.watch(savedPlacesProvider)`
- `isBookmarked` on each card: `ref.read(savedPlacesProvider.notifier).isSaved(place.id)`
- `_showSaveSheet` confirm → `ref.read(savedPlacesProvider.notifier).save(place.id)`
- Build `_selectedTabIndex == 1` content:
  - `AsyncValue.when` on `savedPlacesProvider`
  - data → `ListView` of `_ExploreListCard` rows
  - loading → shimmer rows
  - empty → `EmptyState(icon: Icons.bookmark_border_rounded, title: 'No saved places yet', subtitle: 'Tap the bookmark icon on any place to save it')`

### Files touched
- `lib/services/saved_places_repository.dart` ← new
- `lib/providers/saved_places_provider.dart` ← new
- `lib/providers/api_provider.dart` — register provider
- `lib/screens/discovery/discovery_screen.dart` — replace local state, build saved tab

---

## Phase 7 — Map Markers from Real Data

**Why last:** Purely additive. Needs Phase 3 data live first.

### Changes
- Replace hardcoded `_markers` getter (from `_kAllPlaces`) with markers built from loaded `nearbyPlacesProvider` data across all sections
- Use `BitmapDescriptor.defaultMarkerWithHue` per category (different hue per section type)
- Tap on a marker → `context.push(AppRoutes.place(placeId))`

### Files touched
- `lib/screens/discovery/discovery_screen.dart`

---

## Execution Order

```
Phase 1 → Phase 2 → Phase 4 (GPS) ──┐
                                      ├── Phase 3 (needs lat/lng) → Phase 5 → Phase 6 → Phase 7
                        backend ready ─┘
```

- **Phases 1 & 2** start immediately — no new packages, no backend needed
- **Phase 4** (GPS) can be done in parallel with Phase 2 — just needs pubspec change
- **Phase 3** needs: (a) backend endpoints ready, (b) Phase 4 for real lat/lng
- **Phases 5–7** depend on Phase 3 being live

---

## Verification

| Phase | How to verify |
|---|---|
| 1 | Explore tab → bottom sheet shows 5 sections in correct order, cards scroll horizontally |
| 2 | Tap any card → navigates to place detail screen; back button returns to sheet |
| 3 | Bottom sheet loads real nearby places with shimmer while loading, error state on failure |
| 4 | Tap location button → map moves to device position; nearby data re-fetches around it |
| 5 | Tap a category chip → sheet scrolls to matching section |
| 6 | Bookmark a place → appears in Saved Places tab; persists after app restart |
| 7 | Map has colored markers for loaded places; tapping a marker navigates to detail screen |

---

## Critical Files Reference

| File | Status | Touched in Phase |
|---|---|---|
| `lib/screens/discovery/discovery_screen.dart` | Exists | 1, 2, 3, 4, 5, 6, 7 |
| `lib/screens/discovery/place_detail_screen.dart` | New | 2 |
| `lib/models/place_result.dart` | New | 3 |
| `lib/services/places_repository.dart` | New | 3 |
| `lib/services/saved_places_repository.dart` | New | 6 |
| `lib/providers/places_provider.dart` | New | 3 |
| `lib/providers/location_provider.dart` | New | 4 |
| `lib/providers/saved_places_provider.dart` | New | 6 |
| `lib/providers/api_provider.dart` | Exists | 3, 6 |
| `lib/router/app_router.dart` | Exists | 2 |
| `lib/screens/discovery/widgets/category_filter_bar.dart` | Exists | 5 |
| `pubspec.yaml` | Exists | 4 |
| `android/app/src/main/AndroidManifest.xml` | Exists | 4 |
| `ios/Runner/Info.plist` | Exists | 4 |
