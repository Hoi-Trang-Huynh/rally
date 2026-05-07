import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rally/models/place_result.dart';
import 'package:rally/providers/location_provider.dart';
import 'package:rally/providers/places_provider.dart';
import 'package:rally/providers/saved_places_provider.dart';
import 'package:rally/screens/discovery/widgets/category_filter_bar.dart';
import 'package:rally/themes/app_colors.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/common/scale_button.dart';
import 'package:rally/widgets/common/empty_state.dart';
import 'package:rally/widgets/common/shimmer_loading.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

class _SectionConfig {
  const _SectionConfig({
    required this.title,
    required this.subtitle,
    required this.type,
  });

  final String title;
  final String subtitle;
  final String type;
}

const List<_SectionConfig> _kSectionConfigs = <_SectionConfig>[
  _SectionConfig(
    title: 'Community Recommends',
    subtitle: 'Curated by locals',
    type: 'tourist_attraction',
  ),
  _SectionConfig(
    title: 'Where to Eat',
    subtitle: 'Top-rated restaurants nearby',
    type: 'restaurant',
  ),
  _SectionConfig(
    title: 'Where to Play',
    subtitle: 'Activities & entertainment',
    type: 'amusement_park',
  ),
  _SectionConfig(
    title: 'Where to Drink',
    subtitle: 'Sip, chill & hang out',
    type: 'bar',
  ),
  _SectionConfig(
    title: 'Where to Stay',
    subtitle: 'Accommodations nearby',
    type: 'lodging',
  ),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// The Explore tab — Google Map with a draggable place discovery sheet.
class DiscoveryScreen extends ConsumerStatefulWidget {
  /// Creates a [DiscoveryScreen].
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  int _selectedCategoryIndex = 0;
  GoogleMapController? _mapController;
  String _searchQuery = '';

  static const LatLng _danangCenter = LatLng(16.0544, 108.2022);

  void _zoomIn() {
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToMyLocation() {
    HapticFeedback.lightImpact();
    final LatLng? loc = ref.read(currentLocationProvider).valueOrNull;
    if (loc != null) _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
  }

  Set<Marker> _buildMarkers(LatLng center) {
    final Set<Marker> markers = <Marker>{};
    for (final _SectionConfig section in _kSectionConfigs) {
      final List<PlaceResult> places = ref
              .watch(
                nearbyPlacesProvider(
                  NearbySearchParams(
                    lat: center.latitude,
                    lng: center.longitude,
                    type: section.type,
                  ),
                ),
              )
              .valueOrNull ??
          <PlaceResult>[];
      for (final PlaceResult place in places) {
        markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.lat, place.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _hueForType(section.type),
            ),
            infoWindow: InfoWindow(title: place.name),
            onTap: () =>
                ref.read(markerSelectedPlaceProvider.notifier).state = place,
          ),
        );
      }
    }
    return markers;
  }

  static double _hueForType(String type) {
    switch (type) {
      case 'restaurant':
        return BitmapDescriptor.hueOrange;
      case 'amusement_park':
        return BitmapDescriptor.hueGreen;
      case 'bar':
        return BitmapDescriptor.hueViolet;
      case 'lodging':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng mapCenter =
        ref.watch(currentLocationProvider).valueOrNull ?? _danangCenter;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mapCenter,
              zoom: 13.5,
            ),
            onMapCreated: (GoogleMapController c) => _mapController = c,
            markers: _buildMarkers(mapCenter),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: Responsive.h(context, 10)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 16),
                    ),
                    child: _PlaceSearchBar(
                      onQueryChanged: (String q) =>
                          setState(() => _searchQuery = q),
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 10)),
                  CategoryFilterBar(
                    selectedIndex: _selectedCategoryIndex,
                    onSelected:
                        (int i) => setState(() => _selectedCategoryIndex = i),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: Responsive.w(context, 16),
            bottom: MediaQuery.sizeOf(context).height * 0.47,
            child: _MapControls(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onMyLocation: _goToMyLocation,
            ),
          ),

          Positioned.fill(
            child: _ExploreBottomSheet(
              selectedCategoryIndex: _selectedCategoryIndex,
              center: mapCenter,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _PlaceSearchBar extends StatefulWidget {
  const _PlaceSearchBar({required this.onQueryChanged});

  final ValueChanged<String> onQueryChanged;

  @override
  State<_PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends State<_PlaceSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isActive = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _activate() {
    setState(() => _isActive = true);
    _focusNode.requestFocus();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onQueryChanged(value.trim());
    });
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onQueryChanged('');
    _focusNode.requestFocus();
  }

  void _dismiss() {
    _controller.clear();
    _debounce?.cancel();
    widget.onQueryChanged('');
    _focusNode.unfocus();
    setState(() => _isActive = false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final BoxDecoration containerDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (_isActive) {
      return Container(
        height: Responsive.h(context, 48),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
        decoration: containerDecoration,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search_rounded,
              size: Responsive.w(context, 20),
              color: colorScheme.primary,
            ),
            SizedBox(width: Responsive.w(context, 10)),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                autofocus: true,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search places, food, activities...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: _clear,
                child: Icon(
                  Icons.close_rounded,
                  size: Responsive.w(context, 20),
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              GestureDetector(
                onTap: _dismiss,
                child: Icon(
                  Icons.close_rounded,
                  size: Responsive.w(context, 20),
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _activate();
      },
      child: Container(
        height: Responsive.h(context, 48),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
        decoration: containerDecoration,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search_rounded,
              size: Responsive.w(context, 20),
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: Responsive.w(context, 10)),
            Text(
              'Search places, food, activities...',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map controls
// ---------------------------------------------------------------------------

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onMyLocation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final BoxDecoration cardDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ScaleButton(
                onTap: onZoomIn,
                child: SizedBox(
                  width: Responsive.w(context, 44),
                  height: Responsive.w(context, 44),
                  child: Icon(
                    Icons.add_rounded,
                    size: Responsive.w(context, 20),
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outline.withValues(alpha: 0.2),
                indent: Responsive.w(context, 10),
                endIndent: Responsive.w(context, 10),
              ),
              ScaleButton(
                onTap: onZoomOut,
                child: SizedBox(
                  width: Responsive.w(context, 44),
                  height: Responsive.w(context, 44),
                  child: Icon(
                    Icons.remove_rounded,
                    size: Responsive.w(context, 20),
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Responsive.h(context, 10)),
        Container(
          width: Responsive.w(context, 44),
          height: Responsive.w(context, 44),
          decoration: cardDecoration,
          child: ScaleButton(
            onTap: onMyLocation,
            child: Icon(
              Icons.near_me_rounded,
              size: Responsive.w(context, 20),
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Explore bottom sheet
// ---------------------------------------------------------------------------

// Chip-index → section index mapping (null = "All" → home feed).
// Chip order: All(0), Restaurants(1), Hotels(2), Coffee(3), Activities(4).
// Section order in _kSectionConfigs: Community(0), Eat(1), Play(2), Drink(3), Stay(4).
const List<int?> _kChipToSectionIndex = <int?>[null, 1, 4, 3, 2];

class _ExploreBottomSheet extends ConsumerStatefulWidget {
  const _ExploreBottomSheet({
    required this.selectedCategoryIndex,
    required this.center,
    required this.searchQuery,
  });

  final int selectedCategoryIndex;
  final LatLng center;
  final String searchQuery;

  @override
  ConsumerState<_ExploreBottomSheet> createState() =>
      _ExploreBottomSheetState();
}

class _ExploreBottomSheetState extends ConsumerState<_ExploreBottomSheet> {
  int _selectedTabIndex = 0;
  _SectionConfig? _activeSection;
  PlaceResult? _activePlace;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void didUpdateWidget(_ExploreBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryIndex != widget.selectedCategoryIndex) {
      final int? sectionIdx =
          _kChipToSectionIndex[widget.selectedCategoryIndex];
      if (sectionIdx == null) {
        setState(() {
          _activeSection = null;
          _activePlace = null;
        });
      } else {
        _onSeeMore(_kSectionConfigs[sectionIdx]);
      }
    }
    if (oldWidget.searchQuery != widget.searchQuery) {
      if (widget.searchQuery.isNotEmpty) {
        setState(() {
          _activeSection = null;
          _activePlace = null;
        });
        _sheetController.animateTo(
          0.92,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _onSeeMore(_SectionConfig section) {
    HapticFeedback.lightImpact();
    setState(() {
      _activeSection = section;
      _activePlace = null;
    });
  }

  void _onBackFromDrilldown() {
    HapticFeedback.lightImpact();
    setState(() => _activeSection = null);
  }

  void _onPlaceTap(PlaceResult place) {
    HapticFeedback.lightImpact();
    setState(() {
      _activePlace = place;
      _activeSection = null;
    });
    _sheetController.animateTo(
      0.92,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onCloseDetail() {
    HapticFeedback.lightImpact();
    setState(() => _activePlace = null);
    _sheetController.animateTo(
      0.45,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Bookmark ──────────────────────────────────────────────────────────────

  bool _isSaved(String placeId) =>
      ref
          .watch(savedPlacesProvider)
          .valueOrNull
          ?.any((PlaceResult p) => p.id == placeId) ??
      false;

  void _onBookmark(PlaceResult place) {
    final bool saved =
        ref
            .read(savedPlacesProvider)
            .valueOrNull
            ?.any((PlaceResult p) => p.id == place.id) ??
        false;
    if (saved) {
      HapticFeedback.selectionClick();
      ref.read(savedPlacesProvider.notifier).remove(place.id);
    } else {
      _showSaveSheet(place);
    }
  }

  void _showSaveSheet(PlaceResult place) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showAppBottomSheet<void>(
      context: context,
      sheet: AppBottomSheet.fixed(
        title: 'Save to...',
        showDivider: true,
        handleKeyboard: false,
        action: ScaleButton(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: EdgeInsets.all(Responsive.w(context, 8)),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: Responsive.w(context, 20),
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        body: _SaveToBody(
          placeName: place.name,
          onPersonalLibrary:
              () => ref.read(savedPlacesProvider.notifier).save(place.id),
          onSharedSession:
              () => ref.read(savedPlacesProvider.notifier).save(place.id),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: Responsive.h(context, 12)),
        Center(
          child: Container(
            width: Responsive.w(context, 40),
            height: Responsive.h(context, 4),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(height: Responsive.h(context, 16)),
        if (_activePlace != null)
          // Place detail header: name + bookmark + close
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _activePlace!.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ScaleButton(
                  onTap: () => _onBookmark(_activePlace!),
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 4)),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isSaved(_activePlace!.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        key: ValueKey<bool>(_isSaved(_activePlace!.id)),
                        size: Responsive.w(context, 22),
                        color:
                            _isSaved(_activePlace!.id)
                                ? AppColors.brandGradientStart
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 4)),
                ScaleButton(
                  onTap: _onCloseDetail,
                  child: Container(
                    padding: EdgeInsets.all(Responsive.w(context, 6)),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: Responsive.w(context, 18),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (widget.searchQuery.isNotEmpty)
          // Search header: shows query label (dismiss via search bar X)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.search_rounded,
                  size: Responsive.w(context, 18),
                  color: colorScheme.primary,
                ),
                SizedBox(width: Responsive.w(context, 10)),
                Expanded(
                  child: Text(
                    '"${widget.searchQuery}"',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else if (_activeSection != null)
          // Drilldown header: back + section title
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
            ),
            child: Row(
              children: <Widget>[
                ScaleButton(
                  onTap: _onBackFromDrilldown,
                  child: Padding(
                    padding: EdgeInsets.only(right: Responsive.w(context, 10)),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: Responsive.w(context, 20),
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _activeSection!.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          // Home header: Explore / Saved Places tabs
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Responsive.w(context, 30)),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                ),
                color: colorScheme.surface,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: _ExploreTabButton(
                      label: 'Explore',
                      icon: Icons.explore_rounded,
                      isSelected: _selectedTabIndex == 0,
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  Expanded(
                    child: _ExploreTabButton(
                      label: 'Saved Places',
                      icon:
                          _selectedTabIndex == 1
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                      isSelected: _selectedTabIndex == 1,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: Responsive.h(context, 16)),
        const Divider(height: 1),
      ],
    );
  }

  // ── Home feed slivers ─────────────────────────────────────────────────────

  List<Widget> _buildHomeSlivers(BuildContext context) {
    final List<Widget> slivers = <Widget>[];

    for (final _SectionConfig section in _kSectionConfigs) {
      final AsyncValue<List<PlaceResult>> placesAsync = ref.watch(
        nearbyPlacesProvider(
          NearbySearchParams(
            lat: widget.center.latitude,
            lng: widget.center.longitude,
            type: section.type,
          ),
        ),
      );

      slivers.add(
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: section.title,
            subtitle: section.subtitle,
            onSeeMore: () => _onSeeMore(section),
          ),
        ),
      );

      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: Responsive.h(context, 220),
            child: placesAsync.when(
              loading: () => _buildHorizontalShimmer(context),
              error: (_, __) => const SizedBox.shrink(),
              data:
                  (List<PlaceResult> places) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 16),
                    ),
                    itemCount: places.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      final PlaceResult place = places[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: Responsive.w(context, 12),
                        ),
                        child: SizedBox(
                          width: Responsive.w(context, 160),
                          child: _ExploreHorizontalCard(
                            place: place,
                            isBookmarked: _isSaved(place.id),
                            onTap: () => _onPlaceTap(place),
                            onBookmark: () => _onBookmark(place),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 8))),
      );
    }

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(
          height:
              MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24),
        ),
      ),
    );

    return slivers;
  }

  Widget _buildHorizontalShimmer(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      itemCount: 3,
      itemBuilder:
          (_, __) => Padding(
            padding: EdgeInsets.only(right: Responsive.w(context, 12)),
            child: ShimmerLoading(
              width: Responsive.w(context, 160),
              height: Responsive.h(context, 220),
              borderRadius: Responsive.w(context, 16),
            ),
          ),
    );
  }

  // ── Drill-down slivers ────────────────────────────────────────────────────

  List<Widget> _buildDrilldownSlivers(
    BuildContext context,
    _SectionConfig section,
  ) {
    final AsyncValue<List<PlaceResult>> placesAsync = ref.watch(
      nearbyPlacesProvider(
        NearbySearchParams(
          lat: widget.center.latitude,
          lng: widget.center.longitude,
          type: section.type,
        ),
      ),
    );

    final List<Widget> slivers = <Widget>[];

    placesAsync.when(
      loading: () {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 20),
                Responsive.h(context, 12),
                Responsive.w(context, 20),
                Responsive.h(context, 8),
              ),
              child: ShimmerLoading(
                width: Responsive.w(context, 80),
                height: Responsive.h(context, 14),
                borderRadius: 4,
              ),
            ),
          ),
        );
        for (int i = 0; i < 5; i++) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 20),
                  vertical: Responsive.h(context, 10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ShimmerLoading(
                      width: Responsive.w(context, 76),
                      height: Responsive.w(context, 76),
                      borderRadius: Responsive.w(context, 12),
                    ),
                    SizedBox(width: Responsive.w(context, 14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ShimmerLoading(
                            width: double.infinity,
                            height: Responsive.h(context, 16),
                            borderRadius: 4,
                          ),
                          SizedBox(height: Responsive.h(context, 8)),
                          ShimmerLoading(
                            width: Responsive.w(context, 120),
                            height: Responsive.h(context, 12),
                            borderRadius: 4,
                          ),
                          SizedBox(height: Responsive.h(context, 6)),
                          ShimmerLoading(
                            width: Responsive.w(context, 100),
                            height: Responsive.h(context, 12),
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (i < 4) {
            slivers.add(
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  indent: Responsive.w(context, 20),
                  endIndent: Responsive.w(context, 20),
                ),
              ),
            );
          }
        }
      },
      error: (_, __) {},
      data: (List<PlaceResult> places) {
        final int count = places.length;

        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 20),
                Responsive.h(context, 12),
                Responsive.w(context, 20),
                Responsive.h(context, 8),
              ),
              child: Text(
                '$count places found',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );

        for (int i = 0; i < count; i++) {
          final PlaceResult place = places[i];
          slivers.add(
            SliverToBoxAdapter(
              child: _ExploreListCard(
                place: place,
                isBookmarked: _isSaved(place.id),
                onTap: () => _onPlaceTap(place),
                onBookmark: () => _onBookmark(place),
              ),
            ),
          );
          if (i < count - 1) {
            slivers.add(
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  indent: Responsive.w(context, 20),
                  endIndent: Responsive.w(context, 20),
                ),
              ),
            );
          }
        }
      },
    );

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(
          height:
              MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24),
        ),
      ),
    );

    return slivers;
  }

  // ── Place detail slivers ──────────────────────────────────────────────────

  List<Widget> _buildPlaceDetailSlivers(
    BuildContext context,
    PlaceResult place,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return <Widget>[
      // Hero image
      SliverToBoxAdapter(
        child: SizedBox(
          height: Responsive.h(context, 220),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                place.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        Container(color: colorScheme.surfaceContainer),
              ),
              if (place.type != null)
                Positioned(
                  bottom: Responsive.h(context, 12),
                  left: Responsive.w(context, 16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 10),
                      vertical: Responsive.h(context, 5),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandGradientStart,
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 20),
                      ),
                    ),
                    child: Text(
                      place.type!,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Rating + price
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 20),
            Responsive.h(context, 16),
            Responsive.w(context, 20),
            Responsive.h(context, 4),
          ),
          child: Row(
            children: <Widget>[
              if (place.rating != null) ...<Widget>[
                Icon(
                  Icons.star_rounded,
                  size: Responsive.w(context, 16),
                  color: Colors.amber,
                ),
                SizedBox(width: Responsive.w(context, 4)),
                Text(
                  '${place.rating!.toStringAsFixed(1)} (${_fmtCount(place.reviewCount ?? 0)})',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (place.rating != null && place.priceLevel != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 12),
                  ),
                  child: Container(
                    width: 1,
                    height: Responsive.h(context, 14),
                    color: colorScheme.outline.withValues(alpha: 0.4),
                  ),
                ),
              if (place.priceLevel != null) ...<Widget>[
                Icon(
                  Icons.attach_money_rounded,
                  size: Responsive.w(context, 16),
                  color: colorScheme.onSurfaceVariant,
                ),
                Text(
                  place.priceLevel!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // Description
      if (place.description != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
              vertical: Responsive.h(context, 8),
            ),
            child: Text(
              place.description!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),

      // Location
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 20),
            Responsive.h(context, 8),
            Responsive.w(context, 20),
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: Responsive.w(context, 16),
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Expanded(
                child: Text(
                  place.address ?? 'Da Nang, Vietnam',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Hours
      if (place.hours != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 20),
              Responsive.h(context, 6),
              Responsive.w(context, 20),
              Responsive.h(context, 16),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.access_time_rounded,
                  size: Responsive.w(context, 16),
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: Responsive.w(context, 8)),
                Text(
                  place.hours!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        )
      else
        SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 16))),

      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),

      // More photos
      SliverToBoxAdapter(
        child: _buildDetailSectionHeader(context, 'More photos'),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: Responsive.h(context, 110),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
            ),
            itemCount: 4,
            itemBuilder:
                (_, int i) => Padding(
                  padding: EdgeInsets.only(right: Responsive.w(context, 10)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      Responsive.w(context, 10),
                    ),
                    child: Image.network(
                      place.imageUrl ?? '',
                      width: Responsive.w(context, 140),
                      height: Responsive.h(context, 110),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: Responsive.w(context, 140),
                            color: colorScheme.surfaceContainer,
                          ),
                    ),
                  ),
                ),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 16))),

      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),

      // Opening hours
      SliverToBoxAdapter(
        child: _buildDetailSectionHeader(context, 'Opening hours'),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
          child: Column(
            children: <Widget>[
              _buildHoursRow(context, 'Mon – Fri', '8:00 – 23:00'),
              SizedBox(height: Responsive.h(context, 8)),
              _buildHoursRow(context, 'Sat – Sun', '10:00 – 00:00'),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 16))),

      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),

      // Contact
      SliverToBoxAdapter(child: _buildDetailSectionHeader(context, 'Contact')),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 20),
            0,
            Responsive.w(context, 20),
            Responsive.h(context, 16),
          ),
          child: Row(
            children: <Widget>[
              const _ContactChip(icon: Icons.call_rounded, label: 'Call'),
              SizedBox(width: Responsive.w(context, 10)),
              const _ContactChip(
                icon: Icons.language_rounded,
                label: 'Website',
              ),
              SizedBox(width: Responsive.w(context, 10)),
              const _ContactChip(icon: Icons.map_rounded, label: 'Google Maps'),
            ],
          ),
        ),
      ),

      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),

      // Reviews
      SliverToBoxAdapter(
        child: _buildDetailSectionHeader(
          context,
          'Google reviews · ${_fmtCount(place.reviewCount ?? 0)}',
        ),
      ),
      const SliverToBoxAdapter(
        child: _ReviewCard(
          avatarUrl:
              'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
          name: 'Chris L.',
          daysAgo: '4 days ago',
          stars: 5,
          review:
              'Absolutely wonderful experience! A must-visit when you\'re in Da Nang.',
        ),
      ),
      SliverToBoxAdapter(
        child: Divider(
          height: 1,
          indent: Responsive.w(context, 20),
          endIndent: Responsive.w(context, 20),
        ),
      ),
      const SliverToBoxAdapter(
        child: _ReviewCard(
          avatarUrl:
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          name: 'Ken G.',
          daysAgo: '1 month ago',
          stars: 5,
          review:
              'Iconic landmark. Best experienced in the evening when the lights come on.',
        ),
      ),

      SliverToBoxAdapter(
        child: SizedBox(
          height:
              MediaQuery.paddingOf(context).bottom + Responsive.h(context, 32),
        ),
      ),
    ];
  }

  // ── Detail helper builders ────────────────────────────────────────────────

  Widget _buildDetailSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 20),
        Responsive.h(context, 16),
        Responsive.w(context, 20),
        Responsive.h(context, 12),
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHoursRow(BuildContext context, String day, String time) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          day,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          time,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ── Search slivers ────────────────────────────────────────────────────────

  List<Widget> _buildSearchSlivers(BuildContext context, String query) {
    final AsyncValue<List<PlaceResult>> resultsAsync = ref.watch(
      searchPlacesProvider(
        SearchParams(
          lat: widget.center.latitude,
          lng: widget.center.longitude,
          query: query,
        ),
      ),
    );

    final List<Widget> slivers = <Widget>[];

    resultsAsync.when(
      loading: () {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 20),
                Responsive.h(context, 12),
                Responsive.w(context, 20),
                Responsive.h(context, 8),
              ),
              child: ShimmerLoading(
                width: Responsive.w(context, 100),
                height: Responsive.h(context, 14),
                borderRadius: 4,
              ),
            ),
          ),
        );
        for (int i = 0; i < 5; i++) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 20),
                  vertical: Responsive.h(context, 10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ShimmerLoading(
                      width: Responsive.w(context, 76),
                      height: Responsive.w(context, 76),
                      borderRadius: Responsive.w(context, 12),
                    ),
                    SizedBox(width: Responsive.w(context, 14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ShimmerLoading(
                            width: double.infinity,
                            height: Responsive.h(context, 16),
                            borderRadius: 4,
                          ),
                          SizedBox(height: Responsive.h(context, 8)),
                          ShimmerLoading(
                            width: Responsive.w(context, 120),
                            height: Responsive.h(context, 12),
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (i < 4) {
            slivers.add(
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  indent: Responsive.w(context, 20),
                  endIndent: Responsive.w(context, 20),
                ),
              ),
            );
          }
        }
      },
      error: (_, __) {
        slivers.add(
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Search failed',
                subtitle: 'Something went wrong. Please try again.',
              ),
            ),
          ),
        );
      },
      data: (List<PlaceResult> places) {
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 20),
                Responsive.h(context, 12),
                Responsive.w(context, 20),
                Responsive.h(context, 8),
              ),
              child: Text(
                places.isEmpty
                    ? 'No results'
                    : '${places.length} result${places.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );

        if (places.isEmpty) {
          slivers.add(
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No places found',
                  subtitle: 'Try a different search term',
                ),
              ),
            ),
          );
          return;
        }

        for (int i = 0; i < places.length; i++) {
          final PlaceResult place = places[i];
          slivers.add(
            SliverToBoxAdapter(
              child: _ExploreListCard(
                place: place,
                isBookmarked: _isSaved(place.id),
                onTap: () => _onPlaceTap(place),
                onBookmark: () => _onBookmark(place),
              ),
            ),
          );
          if (i < places.length - 1) {
            slivers.add(
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  indent: Responsive.w(context, 20),
                  endIndent: Responsive.w(context, 20),
                ),
              ),
            );
          }
        }
      },
    );

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24),
        ),
      ),
    );

    return slivers;
  }

  // ── Saved slivers ─────────────────────────────────────────────────────────

  List<Widget> _buildSavedSlivers(BuildContext context) {
    final AsyncValue<List<PlaceResult>> savedAsync =
        ref.watch(savedPlacesProvider);
    final List<Widget> slivers = <Widget>[];

    savedAsync.when(
      loading: () {
        for (int i = 0; i < 5; i++) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 20),
                  vertical: Responsive.h(context, 10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ShimmerLoading(
                      width: Responsive.w(context, 76),
                      height: Responsive.w(context, 76),
                      borderRadius: Responsive.w(context, 12),
                    ),
                    SizedBox(width: Responsive.w(context, 14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ShimmerLoading(
                            width: double.infinity,
                            height: Responsive.h(context, 16),
                            borderRadius: 4,
                          ),
                          SizedBox(height: Responsive.h(context, 8)),
                          ShimmerLoading(
                            width: Responsive.w(context, 120),
                            height: Responsive.h(context, 12),
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
      error: (_, __) {},
      data: (List<PlaceResult> places) {
        if (places.isEmpty) {
          slivers.add(
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No saved places yet',
                  subtitle:
                      'Tap the bookmark icon on any place to save it here',
                ),
              ),
            ),
          );
          return;
        }

        for (int i = 0; i < places.length; i++) {
          final PlaceResult place = places[i];
          slivers.add(
            SliverToBoxAdapter(
              child: _ExploreListCard(
                place: place,
                isBookmarked: true,
                onTap: () => _onPlaceTap(place),
                onBookmark: () => _onBookmark(place),
              ),
            ),
          );
          if (i < places.length - 1) {
            slivers.add(
              SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  indent: Responsive.w(context, 20),
                  endIndent: Responsive.w(context, 20),
                ),
              ),
            );
          }
        }
      },
    );

    slivers.add(
      SliverToBoxAdapter(
        child: SizedBox(
          height:
              MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24),
        ),
      ),
    );

    return slivers;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen<PlaceResult?>(markerSelectedPlaceProvider, (_, PlaceResult? place) {
      if (place != null) {
        _onPlaceTap(place);
        ref.read(markerSelectedPlaceProvider.notifier).state = null;
      }
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final _SectionConfig? activeSection = _activeSection;
    final PlaceResult? activePlace = _activePlace;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const <double>[0.25, 0.45],
      builder: (BuildContext _, ScrollController scrollController) {
        return Material(
          elevation: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: colorScheme.surface,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              Expanded(
                child: CustomScrollView(
                  key: ValueKey<String>(
                    activePlace?.id ??
                        (widget.searchQuery.isNotEmpty
                            ? 'search:${widget.searchQuery}'
                            : activeSection != null
                            ? 'drill:${activeSection.title}'
                            : _selectedTabIndex == 1
                            ? 'saved'
                            : 'home'),
                  ),
                  controller: scrollController,
                  slivers:
                      activePlace != null
                          ? _buildPlaceDetailSlivers(context, activePlace)
                          : widget.searchQuery.isNotEmpty
                          ? _buildSearchSlivers(context, widget.searchQuery)
                          : activeSection != null
                          ? _buildDrilldownSlivers(context, activeSection)
                          : _selectedTabIndex == 1
                          ? _buildSavedSlivers(context)
                          : _buildHomeSlivers(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmtCount(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

// ---------------------------------------------------------------------------
// Tab toggle button
// ---------------------------------------------------------------------------

class _ExploreTabButton extends StatelessWidget {
  const _ExploreTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 16),
          vertical: Responsive.h(context, 10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGradientStart : Colors.transparent,
          borderRadius: BorderRadius.circular(Responsive.w(context, 30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: Responsive.w(context, 15),
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: Responsive.w(context, 6)),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onSeeMore,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onSeeMore;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 20),
        Responsive.h(context, 16),
        Responsive.w(context, 20),
        Responsive.h(context, 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.h(context, 2)),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onSeeMore != null)
            ScaleButton(
              onTap: onSeeMore!,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'See more',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.brandGradientStart,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 2)),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: Responsive.w(context, 11),
                    color: AppColors.brandGradientStart,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal card — places
// ---------------------------------------------------------------------------

class _ExploreHorizontalCard extends StatelessWidget {
  const _ExploreHorizontalCard({
    required this.place,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final PlaceResult place;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Responsive.w(context, 16)),
                      topRight: Radius.circular(Responsive.w(context, 16)),
                    ),
                    child: Image.network(
                      place.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              Container(color: colorScheme.surfaceContainer),
                    ),
                  ),
                  if (place.pricePerNight != null)
                    Positioned(
                      bottom: Responsive.h(context, 8),
                      left: Responsive.w(context, 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 8),
                          vertical: Responsive.h(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(
                            Responsive.w(context, 10),
                          ),
                        ),
                        child: Text(
                          place.pricePerNight!,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: Responsive.h(context, 8),
                    right: Responsive.w(context, 8),
                    child: ScaleButton(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onBookmark();
                      },
                      child: Container(
                        padding: EdgeInsets.all(Responsive.w(context, 6)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            key: ValueKey<bool>(isBookmarked),
                            size: Responsive.w(context, 16),
                            color:
                                isBookmarked
                                    ? AppColors.brandGradientStart
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 10),
                  vertical: Responsive.h(context, 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      place.name,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.star_rounded,
                          size: Responsive.w(context, 12),
                          color: Colors.amber,
                        ),
                        SizedBox(width: Responsive.w(context, 2)),
                        Flexible(
                          child: Text(
                            _ratingText(place),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.access_time_rounded,
                          size: Responsive.w(context, 11),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: Responsive.w(context, 3)),
                        Flexible(
                          child: Text(
                            _hoursDistanceText(place),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingText(PlaceResult p) {
    final String rating = p.rating != null ? p.rating!.toStringAsFixed(1) : '–';
    final String reviews = p.reviewCount != null ? _fmt(p.reviewCount!) : '0';
    final String price = p.priceLevel ?? '';
    return '$rating ($reviews)${price.isNotEmpty ? ' · $price' : ''}';
  }

  String _hoursDistanceText(PlaceResult p) {
    final List<String> parts = <String>[
      if (p.hours != null) p.hours!,
      if (p.distance != null) p.distance!,
    ];
    return parts.isNotEmpty ? parts.join(' · ') : '–';
  }

  String _fmt(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

// ---------------------------------------------------------------------------
// List card — drill-down view
// ---------------------------------------------------------------------------

class _ExploreListCard extends StatelessWidget {
  const _ExploreListCard({
    required this.place,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final PlaceResult place;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 20),
          vertical: Responsive.h(context, 10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              child: Image.network(
                place.imageUrl ?? '',
                width: Responsive.w(context, 76),
                height: Responsive.w(context, 76),
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: Responsive.w(context, 76),
                      height: Responsive.w(context, 76),
                      color: colorScheme.surfaceContainer,
                      child: Icon(
                        Icons.image_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: Responsive.w(context, 28),
                      ),
                    ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    place.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.h(context, 4)),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.star_rounded,
                        size: Responsive.w(context, 14),
                        color: Colors.amber,
                      ),
                      SizedBox(width: Responsive.w(context, 3)),
                      Text(
                        place.rating != null
                            ? '${place.rating!.toStringAsFixed(1)} (${_fmt(place.reviewCount ?? 0)})'
                            : '–',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (place.priceLevel != null)
                        Text(
                          '  ·  ${place.priceLevel!}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 5)),
                  Row(
                    children: <Widget>[
                      if (place.hours != null) ...<Widget>[
                        Icon(
                          Icons.access_time_rounded,
                          size: Responsive.w(context, 12),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: Responsive.w(context, 3)),
                        Text(
                          place.hours!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: Responsive.w(context, 10)),
                      ],
                      if (place.distance != null) ...<Widget>[
                        Icon(
                          Icons.location_on_rounded,
                          size: Responsive.w(context, 12),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: Responsive.w(context, 3)),
                        Text(
                          place.distance!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            ScaleButton(
              onTap: () {
                HapticFeedback.selectionClick();
                onBookmark();
              },
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(context, 4)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    key: ValueKey<bool>(isBookmarked),
                    size: Responsive.w(context, 22),
                    color:
                        isBookmarked
                            ? AppColors.brandGradientStart
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

// ---------------------------------------------------------------------------
// Contact chip (place detail)
// ---------------------------------------------------------------------------

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 14),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: Responsive.w(context, 14),
              color: AppColors.brandGradientStart,
            ),
            SizedBox(width: Responsive.w(context, 6)),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Review card (place detail)
// ---------------------------------------------------------------------------

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.avatarUrl,
    required this.name,
    required this.daysAgo,
    required this.stars,
    required this.review,
  });

  final String avatarUrl;
  final String name;
  final String daysAgo;
  final int stars;
  final String review;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 20),
        vertical: Responsive.h(context, 12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipOval(
            child: Image.network(
              avatarUrl,
              width: Responsive.w(context, 40),
              height: Responsive.w(context, 40),
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: Responsive.w(context, 40),
                    height: Responsive.w(context, 40),
                    color: colorScheme.surfaceContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: Responsive.w(context, 22),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
            ),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      daysAgo,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Row(
                  children: List<Widget>.generate(
                    5,
                    (int i) => Icon(
                      Icons.star_rounded,
                      size: Responsive.w(context, 14),
                      color:
                          i < stars
                              ? Colors.amber
                              : colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 6)),
                Text(
                  review,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Save-to sheet body
// ---------------------------------------------------------------------------

class _SaveToBody extends StatelessWidget {
  const _SaveToBody({
    required this.placeName,
    this.onPersonalLibrary,
    this.onSharedSession,
  });

  final String placeName;
  final VoidCallback? onPersonalLibrary;
  final VoidCallback? onSharedSession;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 24),
            0,
            Responsive.w(context, 24),
            Responsive.h(context, 20),
          ),
          child: Text(
            placeName,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _SaveOption(
          icon: Icons.lock_rounded,
          iconColor: const Color(0xFF7C6CF2),
          iconBgColor: const Color(0xFFEDE9FF),
          title: 'Personal Library',
          subtitle: 'Private — only you can see',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            onPersonalLibrary?.call();
          },
        ),
        SizedBox(height: Responsive.h(context, 4)),
        _SaveOption(
          icon: Icons.group_rounded,
          iconColor: const Color(0xFFFF551D),
          iconBgColor: const Color(0xFFFFEDE9),
          title: 'Shared Session Library',
          subtitle: 'Save to one or more trips',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            onSharedSession?.call();
          },
        ),
      ],
    );
  }
}

class _SaveOption extends StatelessWidget {
  const _SaveOption({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ScaleButton(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 16),
            vertical: Responsive.h(context, 14),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: Responsive.w(context, 44),
                height: Responsive.w(context, 44),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: Responsive.w(context, 22),
                ),
              ),
              SizedBox(width: Responsive.w(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: Responsive.w(context, 14),
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
