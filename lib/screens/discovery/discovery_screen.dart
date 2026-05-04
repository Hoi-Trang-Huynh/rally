import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rally/themes/app_colors.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/common/scale_button.dart';
import 'package:rally/screens/discovery/widgets/category_filter_bar.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

enum _SectionCardType { placeGrid, collectionGrid }

class _Place {
  const _Place({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.hours,
    required this.distance,
    required this.latLng,
    this.badge,
    this.pricePerNight,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String price;
  final String hours;
  final String distance;
  final LatLng latLng;
  final String? badge;
  final String? pricePerNight;
}

class _Collection {
  const _Collection({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.locationCount,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorName;
  final String authorAvatarUrl;
  final int locationCount;
}

class _PlaceSection {
  const _PlaceSection({
    required this.title,
    required this.subtitle,
    this.places = const <_Place>[],
    this.collections = const <_Collection>[],
    this.cardType = _SectionCardType.placeGrid,
    this.showTrendingChip = false,
  });

  final String title;
  final String subtitle;
  final List<_Place> places;
  final List<_Collection> collections;
  final _SectionCardType cardType;
  final bool showTrendingChip;

  int get itemCount =>
      cardType == _SectionCardType.collectionGrid ? collections.length : places.length;
}

const List<_PlaceSection> _kSections = <_PlaceSection>[
  _PlaceSection(
    title: 'Trending Places',
    subtitle: 'Popular spots this week',
    showTrendingChip: true,
    places: <_Place>[
      _Place(
        id: 'dragon-bridge',
        name: 'Dragon Bridge',
        imageUrl: 'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=600',
        rating: 4.4,
        reviewCount: 2340,
        price: 'Free',
        hours: 'Open 24h',
        distance: '1.2 km',
        latLng: LatLng(16.0609, 108.2272),
        badge: 'Trending',
      ),
      _Place(
        id: 'my-khe-beach',
        name: 'My Khe Beach',
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600',
        rating: 4.5,
        reviewCount: 5120,
        price: 'Free',
        hours: 'Open 24h',
        distance: '2.8 km',
        latLng: LatLng(16.0635, 108.2470),
        badge: 'Trending',
      ),
      _Place(
        id: 'marble-mountains',
        name: 'Marble Mountains',
        imageUrl: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=600',
        rating: 4.7,
        reviewCount: 3892,
        price: r'$',
        hours: '7AM–5:30PM',
        distance: '5.1 km',
        latLng: LatLng(15.9731, 108.2625),
        badge: 'Hot',
      ),
      _Place(
        id: 'ba-na-hills',
        name: 'Ba Na Hills',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
        rating: 4.6,
        reviewCount: 4210,
        price: r'$$',
        hours: '7AM–10PM',
        distance: '25 km',
        latLng: LatLng(15.9973, 107.9882),
        badge: 'Popular',
      ),
      _Place(
        id: 'son-tra-peninsula',
        name: 'Son Tra Peninsula',
        imageUrl: 'https://images.unsplash.com/photo-1540202403-b7abd6747a18?w=600',
        rating: 4.8,
        reviewCount: 1560,
        price: 'Free',
        hours: 'Open 24h',
        distance: '8.3 km',
        latLng: LatLng(16.1055, 108.2862),
        badge: 'Trending',
      ),
    ],
  ),
  _PlaceSection(
    title: 'Where to Eat',
    subtitle: 'Top-rated restaurants nearby',
    places: <_Place>[
      _Place(
        id: 'be-man-seafood',
        name: 'Be Man Seafood',
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600',
        rating: 4.6,
        reviewCount: 1247,
        price: r'$$',
        hours: '10AM–10PM',
        distance: '0.8 km',
        latLng: LatLng(16.0472, 108.2241),
      ),
      _Place(
        id: 'mi-quang-ba-mua',
        name: 'Mi Quang Ba Mua',
        imageUrl: 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=600',
        rating: 4.5,
        reviewCount: 890,
        price: r'$',
        hours: '6AM–9PM',
        distance: '1.5 km',
        latLng: LatLng(16.0521, 108.2199),
      ),
    ],
  ),
  _PlaceSection(
    title: 'Where to Play',
    subtitle: 'Fun activities & entertainment',
    places: <_Place>[
      _Place(
        id: 'asia-park',
        name: 'Asia Park',
        imageUrl: 'https://images.unsplash.com/photo-1549060279-7e168fcee0c2?w=600',
        rating: 4.3,
        reviewCount: 1890,
        price: r'$$',
        hours: '3PM–10PM',
        distance: '3.5 km',
        latLng: LatLng(16.0396, 108.2171),
      ),
      _Place(
        id: 'surf-shack',
        name: 'Surf Shack Da Nang',
        imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=600',
        rating: 4.6,
        reviewCount: 340,
        price: r'$$',
        hours: '6AM–6PM',
        distance: '2.8 km',
        latLng: LatLng(16.0590, 108.2453),
      ),
    ],
  ),
  _PlaceSection(
    title: 'Community Recommends',
    subtitle: 'Curated by locals',
    cardType: _SectionCardType.collectionGrid,
    collections: <_Collection>[
      _Collection(
        id: 'da-nang-gems',
        title: 'Hidden Da Nang Gems',
        description: 'Curated spots locals love but tourists miss',
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
        authorName: 'Minh Tran',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
        locationCount: 8,
      ),
      _Collection(
        id: 'beachside-eats',
        title: 'Beachside Eats & Drinks',
        description: 'Best spots along the Da Nang coastline',
        imageUrl: 'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=600',
        authorName: 'Linh Pham',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        locationCount: 12,
      ),
    ],
  ),
  _PlaceSection(
    title: 'Where to Stay',
    subtitle: 'Hotels & accommodations',
    places: <_Place>[
      _Place(
        id: 'mercure-danang',
        name: 'Mercure Da Nang',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600',
        rating: 4.7,
        reviewCount: 2340,
        price: r'$$$',
        hours: 'Check-in 2PM',
        distance: '3.2 km',
        latLng: LatLng(16.0511, 108.2248),
        pricePerNight: r'$80/night',
      ),
      _Place(
        id: 'pullman-danang',
        name: 'Pullman Da Nang Beach',
        imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=600',
        rating: 4.8,
        reviewCount: 1890,
        price: r'$$$$',
        hours: 'Check-in 2PM',
        distance: '5.0 km',
        latLng: LatLng(16.0631, 108.2498),
        pricePerNight: r'$180/night',
      ),
    ],
  ),
];

List<_Place> get _kAllPlaces => _kSections
    .where((_PlaceSection s) => s.cardType != _SectionCardType.collectionGrid)
    .expand((_PlaceSection s) => s.places)
    .toList();

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

  static const LatLng _danangCenter = LatLng(16.0544, 108.2022);

  Set<Marker> get _markers => _kAllPlaces.map((_Place p) {
        return Marker(
          markerId: MarkerId(p.id),
          position: p.latLng,
          infoWindow: InfoWindow(title: p.name),
        );
      }).toSet();

  void _zoomIn() {
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _goToMyLocation() => HapticFeedback.lightImpact();

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: _danangCenter, zoom: 13.5),
            onMapCreated: (GoogleMapController c) => _mapController = c,
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
            },
          ),

          // Search bar + category chips
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
                    padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
                    child: const _PlaceSearchBar(),
                  ),
                  SizedBox(height: Responsive.h(context, 10)),
                  CategoryFilterBar(
                    selectedIndex: _selectedCategoryIndex,
                    onSelected: (int i) => setState(() => _selectedCategoryIndex = i),
                  ),
                ],
              ),
            ),
          ),

          // Map controls — vertical pill for zoom + separate location button
          Positioned(
            right: Responsive.w(context, 16),
            bottom: MediaQuery.sizeOf(context).height * 0.47,
            child: _MapControls(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onMyLocation: _goToMyLocation,
            ),
          ),

          // Draggable discovery sheet — Positioned.fill is required so
          // DraggableScrollableSheet resolves child-size fractions against
          // a finite parent height.
          const Positioned.fill(child: _ExploreBottomSheet()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _PlaceSearchBar extends StatelessWidget {
  const _PlaceSearchBar();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        height: Responsive.h(context, 48),
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search_rounded, size: Responsive.w(context, 20), color: colorScheme.onSurfaceVariant),
            SizedBox(width: Responsive.w(context, 10)),
            Text(
              'Search places, food, activities...',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map controls — vertical pill with +/- and separate location button
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
                  child: Icon(Icons.add_rounded, size: Responsive.w(context, 20), color: colorScheme.onSurface),
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
                  child: Icon(Icons.remove_rounded, size: Responsive.w(context, 20), color: colorScheme.onSurface),
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
            child: Icon(Icons.near_me_rounded, size: Responsive.w(context, 20), color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Explore bottom sheet
// ---------------------------------------------------------------------------

class _ExploreBottomSheet extends StatefulWidget {
  const _ExploreBottomSheet();

  @override
  State<_ExploreBottomSheet> createState() => _ExploreBottomSheetState();
}

class _ExploreBottomSheetState extends State<_ExploreBottomSheet> {
  int _selectedTabIndex = 0;
  final Set<String> _bookmarkedIds = <String>{};
  _PlaceSection? _activeSection;

  void _onSeeMore(_PlaceSection section) {
    HapticFeedback.lightImpact();
    setState(() => _activeSection = section);
  }

  void _onBackFromDrilldown() {
    HapticFeedback.lightImpact();
    setState(() => _activeSection = null);
  }

  void _onBookmark(_Place place) {
    if (_bookmarkedIds.contains(place.id)) {
      HapticFeedback.selectionClick();
      setState(() => _bookmarkedIds.remove(place.id));
    } else {
      _showSaveSheet(place);
    }
  }

  void _showSaveSheet(_Place place) {
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
            child: Icon(Icons.close_rounded, size: Responsive.w(context, 20), color: colorScheme.onSurfaceVariant),
          ),
        ),
        body: _SaveToBody(
          placeName: place.name,
          onPersonalLibrary: () => setState(() => _bookmarkedIds.add(place.id)),
          onSharedSession: () => setState(() => _bookmarkedIds.add(place.id)),
        ),
      ),
    );
  }

  // Header: drag handle + tab switcher or drill-down back row
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
        if (_activeSection != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
            child: Row(
              children: <Widget>[
                ScaleButton(
                  onTap: _onBackFromDrilldown,
                  child: Padding(
                    padding: EdgeInsets.only(right: Responsive.w(context, 10)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: Responsive.w(context, 20), color: colorScheme.onSurface),
                  ),
                ),
                Expanded(
                  child: Text(
                    _activeSection!.title,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ExploreTabButton(
                  label: 'Explore',
                  icon: Icons.explore_rounded,
                  isSelected: _selectedTabIndex == 0,
                  onTap: () => setState(() => _selectedTabIndex = 0),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                SizedBox(width: Responsive.w(context, 8)),
                _ExploreTabButton(
                  label: 'Saved Places',
                  icon: Icons.bookmark_rounded,
                  isSelected: _selectedTabIndex == 1,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        SizedBox(height: Responsive.h(context, 16)),
        const Divider(height: 1),
      ],
    );
  }

  List<Widget> _buildHomeSlivers(BuildContext context) {
    final List<Widget> slivers = <Widget>[];

    for (final _PlaceSection section in _kSections) {
      slivers.add(
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: section.title,
            subtitle: section.subtitle,
            onSeeMore: section.cardType == _SectionCardType.placeGrid
                ? () => _onSeeMore(section)
                : null,
          ),
        ),
      );

      if (section.showTrendingChip) {
        slivers.add(const SliverToBoxAdapter(child: _TrendingOnMapsChip()));
      }

      final SliverChildBuilderDelegate gridDelegate;
      if (section.cardType == _SectionCardType.collectionGrid) {
        gridDelegate = SliverChildBuilderDelegate(
          (BuildContext _, int index) => _CollectionGridCard(
            collection: section.collections[index],
            onTap: () => HapticFeedback.lightImpact(),
          ),
          childCount: section.collections.length,
        );
      } else {
        gridDelegate = SliverChildBuilderDelegate(
          (BuildContext _, int index) {
            final _Place place = section.places[index];
            return _ExploreGridCard(
              place: place,
              isBookmarked: _bookmarkedIds.contains(place.id),
              onTap: () => HapticFeedback.lightImpact(),
              onBookmark: () => _onBookmark(place),
            );
          },
          childCount: section.places.length,
        );
      }

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: Responsive.w(context, 10),
              mainAxisSpacing: Responsive.h(context, 10),
              childAspectRatio: 0.72,
            ),
            delegate: gridDelegate,
          ),
        ),
      );

      slivers.add(SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 12))));
    }

    slivers.add(SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24)),
    ));

    return slivers;
  }

  List<Widget> _buildDrilldownSlivers(BuildContext context, _PlaceSection section) {
    final List<Widget> slivers = <Widget>[];
    final int count = section.places.length;

    slivers.add(SliverToBoxAdapter(
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
    ));

    for (int i = 0; i < count; i++) {
      final _Place place = section.places[i];
      slivers.add(SliverToBoxAdapter(
        child: _ExploreListCard(
          place: place,
          isBookmarked: _bookmarkedIds.contains(place.id),
          onTap: () => HapticFeedback.lightImpact(),
          onBookmark: () => _onBookmark(place),
        ),
      ));
      if (i < count - 1) {
        slivers.add(SliverToBoxAdapter(
          child: Divider(
            height: 1,
            indent: Responsive.w(context, 20),
            endIndent: Responsive.w(context, 20),
          ),
        ));
      }
    }

    slivers.add(SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24)),
    ));

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final _PlaceSection? activeSection = _activeSection;

    return DraggableScrollableSheet(
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
                  key: ValueKey<bool>(activeSection != null),
                  controller: scrollController,
                  slivers: activeSection != null
                      ? _buildDrilldownSlivers(context, activeSection)
                      : _buildHomeSlivers(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
          border: isSelected
              ? null
              : Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
                Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: Responsive.h(context, 2)),
                Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
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
                  Icon(Icons.arrow_forward_ios_rounded, size: Responsive.w(context, 11), color: AppColors.brandGradientStart),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Trending on Maps" chip
// ---------------------------------------------------------------------------

class _TrendingOnMapsChip extends StatelessWidget {
  const _TrendingOnMapsChip();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(left: Responsive.w(context, 20), bottom: Responsive.h(context, 10)),
      child: ScaleButton(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 14),
            vertical: Responsive.h(context, 8),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.local_fire_department_rounded, size: Responsive.w(context, 15), color: AppColors.brandGradientStart),
              SizedBox(width: Responsive.w(context, 6)),
              Text('Trending on Maps', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
              SizedBox(width: Responsive.w(context, 6)),
              Icon(Icons.location_on_rounded, size: Responsive.w(context, 14), color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2-column grid card — places
// ---------------------------------------------------------------------------

class _ExploreGridCard extends StatelessWidget {
  const _ExploreGridCard({
    required this.place,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final _Place place;
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
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
                    child: Image.network(place.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainer)),
                  ),
                  if (place.badge != null)
                    Positioned(
                      top: Responsive.h(context, 8),
                      left: Responsive.w(context, 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 4)),
                        decoration: BoxDecoration(color: AppColors.brandGradientStart, borderRadius: BorderRadius.circular(Responsive.w(context, 10))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          Icon(Icons.local_fire_department_rounded, size: Responsive.w(context, 11), color: Colors.white),
                          SizedBox(width: Responsive.w(context, 3)),
                          Text(place.badge!, style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  if (place.pricePerNight != null)
                    Positioned(
                      bottom: Responsive.h(context, 8),
                      left: Responsive.w(context, 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 4)),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(Responsive.w(context, 10))),
                        child: Text(place.pricePerNight!, style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: Responsive.h(context, 8),
                    right: Responsive.w(context, 8),
                    child: ScaleButton(
                      onTap: () { HapticFeedback.selectionClick(); onBookmark(); },
                      child: Container(
                        padding: EdgeInsets.all(Responsive.w(context, 6)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4)],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            key: ValueKey<bool>(isBookmarked),
                            size: Responsive.w(context, 16),
                            color: isBookmarked ? AppColors.brandGradientStart : colorScheme.onSurfaceVariant,
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
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 10), vertical: Responsive.h(context, 8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(place.name, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Row(children: <Widget>[
                      Icon(Icons.star_rounded, size: Responsive.w(context, 12), color: Colors.amber),
                      SizedBox(width: Responsive.w(context, 2)),
                      Flexible(child: Text(
                        '${place.rating} (${_fmt(place.reviewCount)}) · ${place.price}',
                        style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                    Row(children: <Widget>[
                      Icon(Icons.access_time_rounded, size: Responsive.w(context, 11), color: colorScheme.onSurfaceVariant),
                      SizedBox(width: Responsive.w(context, 3)),
                      Flexible(child: Text(
                        '${place.hours} · ${place.distance}',
                        style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int count) => count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

// ---------------------------------------------------------------------------
// 2-column grid card — collections
// ---------------------------------------------------------------------------

class _CollectionGridCard extends StatelessWidget {
  const _CollectionGridCard({required this.collection, required this.onTap});

  final _Collection collection;
  final VoidCallback onTap;

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
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
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
                    child: Image.network(collection.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainer)),
                  ),
                  Positioned(
                    top: Responsive.h(context, 8),
                    right: Responsive.w(context, 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8), vertical: Responsive.h(context, 4)),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(Responsive.w(context, 10))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Icon(Icons.location_on_rounded, size: Responsive.w(context, 11), color: Colors.white),
                        SizedBox(width: Responsive.w(context, 3)),
                        Text('${collection.locationCount}', style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                  Positioned(
                    bottom: Responsive.h(context, 8),
                    left: Responsive.w(context, 8),
                    child: Container(
                      width: Responsive.w(context, 28),
                      height: Responsive.w(context, 28),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: ClipOval(
                        child: Image.network(collection.authorAvatarUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.brandGradientStart,
                              child: Icon(Icons.person_rounded, color: Colors.white, size: Responsive.w(context, 16)),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 10), vertical: Responsive.h(context, 8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(collection.title, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Flexible(child: Text(
                      collection.description,
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal list card — drill-down view
// ---------------------------------------------------------------------------

class _ExploreListCard extends StatelessWidget {
  const _ExploreListCard({
    required this.place,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  final _Place place;
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
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20), vertical: Responsive.h(context, 10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
              child: Image.network(place.imageUrl,
                width: Responsive.w(context, 76), height: Responsive.w(context, 76), fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: Responsive.w(context, 76), height: Responsive.w(context, 76),
                  color: colorScheme.surfaceContainer,
                  child: Icon(Icons.image_rounded, color: colorScheme.onSurfaceVariant, size: Responsive.w(context, 28)),
                )),
            ),
            SizedBox(width: Responsive.w(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(place.name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: Responsive.h(context, 4)),
                  Row(children: <Widget>[
                    Icon(Icons.star_rounded, size: Responsive.w(context, 14), color: Colors.amber),
                    SizedBox(width: Responsive.w(context, 3)),
                    Text('${place.rating} (${_fmt(place.reviewCount)})', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text('  ·  ${place.price}', style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ]),
                  SizedBox(height: Responsive.h(context, 5)),
                  Row(children: <Widget>[
                    Icon(Icons.access_time_rounded, size: Responsive.w(context, 12), color: colorScheme.onSurfaceVariant),
                    SizedBox(width: Responsive.w(context, 3)),
                    Text(place.hours, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    SizedBox(width: Responsive.w(context, 10)),
                    Icon(Icons.location_on_rounded, size: Responsive.w(context, 12), color: colorScheme.onSurfaceVariant),
                    SizedBox(width: Responsive.w(context, 3)),
                    Text(place.distance, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ]),
                ],
              ),
            ),
            ScaleButton(
              onTap: () { HapticFeedback.selectionClick(); onBookmark(); },
              child: Padding(
                padding: EdgeInsets.all(Responsive.w(context, 4)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    key: ValueKey<bool>(isBookmarked),
                    size: Responsive.w(context, 22),
                    color: isBookmarked ? AppColors.brandGradientStart : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int count) => count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
}

// ---------------------------------------------------------------------------
// Save-to sheet body
// ---------------------------------------------------------------------------

class _SaveToBody extends StatelessWidget {
  const _SaveToBody({required this.placeName, this.onPersonalLibrary, this.onSharedSession});

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
          padding: EdgeInsets.fromLTRB(Responsive.w(context, 24), 0, Responsive.w(context, 24), Responsive.h(context, 20)),
          child: Text(placeName, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ),
        _SaveOption(
          icon: Icons.lock_rounded,
          iconColor: const Color(0xFF7C6CF2),
          iconBgColor: const Color(0xFFEDE9FF),
          title: 'Personal Library',
          subtitle: 'Private — only you can see',
          onTap: () { HapticFeedback.lightImpact(); Navigator.of(context).pop(); onPersonalLibrary?.call(); },
        ),
        SizedBox(height: Responsive.h(context, 4)),
        _SaveOption(
          icon: Icons.group_rounded,
          iconColor: const Color(0xFFFF551D),
          iconBgColor: const Color(0xFFFFEDE9),
          title: 'Shared Session Library',
          subtitle: 'Save to one or more trips',
          onTap: () { HapticFeedback.lightImpact(); Navigator.of(context).pop(); onSharedSession?.call(); },
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
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16), vertical: Responsive.h(context, 14)),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: Responsive.w(context, 44),
                height: Responsive.w(context, 44),
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: Responsive.w(context, 22)),
              ),
              SizedBox(width: Responsive.w(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: Responsive.w(context, 14), color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
