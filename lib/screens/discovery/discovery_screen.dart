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
import 'package:rally/providers/location_provider.dart';
import 'package:rally/screens/discovery/widgets/category_filter_bar.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

enum _SectionCardType { placeList, collectionList }

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
    required this.category,
    this.description,
    this.address,
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
  final String category;
  final String? description;
  final String? address;
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
    this.cardType = _SectionCardType.placeList,
  });

  final String title;
  final String subtitle;
  final List<_Place> places;
  final List<_Collection> collections;
  final _SectionCardType cardType;
}

const List<_PlaceSection> _kSections = <_PlaceSection>[
  _PlaceSection(
    title: 'Community Recommends',
    subtitle: 'Curated by locals',
    cardType: _SectionCardType.collectionList,
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
      _Collection(
        id: 'sunrise-spots',
        title: 'Best Sunrise Spots',
        description: 'Catch the sunrise at these magical views',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600',
        authorName: 'An Nguyen',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        locationCount: 5,
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
        category: 'Seafood',
        description: 'A beloved local seafood spot serving fresh catches from the East Sea. Known for grilled fish, shrimp, and crab at great prices.',
        address: '10 Tran Phu, Hai Chau, Da Nang',
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
        category: 'Vietnamese',
        description: 'Authentic Mi Quang — a Central Vietnamese noodle dish with turmeric-tinted noodles, pork, shrimp, and fresh herbs.',
        address: '35 Tran Binh Trong, Hai Chau, Da Nang',
      ),
      _Place(
        id: 'banh-mi-phuong',
        name: 'Banh Mi Phuong',
        imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=600',
        rating: 4.7,
        reviewCount: 3200,
        price: r'$',
        hours: '6AM–9PM',
        distance: '2.1 km',
        latLng: LatLng(16.0469, 108.2235),
        category: 'Street Food',
        description: 'Famous banh mi shop known worldwide for its crispy baguette loaded with pâté, cold cuts, and pickled vegetables.',
        address: '2B Phan Chu Trinh, Hai Chau, Da Nang',
      ),
      _Place(
        id: 'madame-lan',
        name: 'Madame Lan Restaurant',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600',
        rating: 4.4,
        reviewCount: 760,
        price: r'$$',
        hours: '10AM–10PM',
        distance: '3.0 km',
        latLng: LatLng(16.0601, 108.2280),
        category: 'Vietnamese',
        description: 'Upscale Vietnamese dining in a beautifully restored colonial building. Great for groups and special occasions.',
        address: '4 Bach Dang, Hai Chau, Da Nang',
      ),
    ],
  ),
  _PlaceSection(
    title: 'Where to Play',
    subtitle: 'Activities & entertainment',
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
        category: 'Amusement Park',
        description: 'A large amusement park featuring the iconic Sun Wheel — one of the largest Ferris wheels in Asia — plus rides and cultural pavilions.',
        address: '1 Phan Dang Luu, Hai Chau, Da Nang',
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
        category: 'Water Sports',
        description: 'Learn to surf on My Khe Beach with certified instructors. Board rental, lessons for all levels, and a chill beach vibe.',
        address: 'My Khe Beach, Son Tra, Da Nang',
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
        category: 'Attraction',
        description: 'Five marble and limestone hills with caves, tunnels, and Buddhist sanctuaries. Climb to the summit for panoramic views over Da Nang.',
        address: '52 Huyen Tran Cong Chua, Ngu Hanh Son, Da Nang',
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
        category: 'Nature',
        description: 'A forested peninsula jutting into the sea, home to the golden Linh Ung Pagoda and rare red-shanked douc langurs.',
        address: 'Son Tra Peninsula, Son Tra, Da Nang',
      ),
    ],
  ),
  _PlaceSection(
    title: 'Where to Drink',
    subtitle: 'Sip, chill & hang out',
    places: <_Place>[
      _Place(
        id: 'sky36-bar',
        name: 'SKY36 Rooftop Bar',
        imageUrl: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=600',
        rating: 4.5,
        reviewCount: 1120,
        price: r'$$$',
        hours: '5PM–2AM',
        distance: '1.8 km',
        latLng: LatLng(16.0623, 108.2230),
        category: 'Rooftop Bar',
        description: 'Da Nang\'s highest rooftop bar on the 36th floor of the Novotel. Stunning views of the Han River, great cocktails and DJ sets on weekends.',
        address: '36 Bach Dang, Hai Chau, Da Nang',
      ),
      _Place(
        id: 'the-rooftop-bar',
        name: 'The Rooftop Bar',
        imageUrl: 'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2?w=600',
        rating: 4.3,
        reviewCount: 680,
        price: r'$$',
        hours: '4PM–1AM',
        distance: '0.9 km',
        latLng: LatLng(16.0571, 108.2218),
        category: 'Bar',
        description: 'Relaxed rooftop bar with river views, craft beers, and a buzzing happy hour from 4–6PM daily.',
        address: '12 Tran Phu, Hai Chau, Da Nang',
      ),
      _Place(
        id: 'young-cafe',
        name: 'Young Café',
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
        rating: 4.4,
        reviewCount: 540,
        price: r'$',
        hours: '7AM–11PM',
        distance: '1.2 km',
        latLng: LatLng(16.0508, 108.2260),
        category: 'Café',
        description: 'A cozy multi-level café popular with students and remote workers. Great Vietnamese iced coffee, smoothies, and light bites.',
        address: '22 Hoang Dieu, Hai Chau, Da Nang',
      ),
      _Place(
        id: 'waterfront-bar',
        name: 'Waterfront Bar',
        imageUrl: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=600',
        rating: 4.2,
        reviewCount: 430,
        price: r'$$',
        hours: '3PM–12AM',
        distance: '2.4 km',
        latLng: LatLng(16.0655, 108.2301),
        category: 'Bar',
        description: 'Riverside bar with a breezy terrace, live music on Friday nights, and a solid selection of imported craft beers.',
        address: '150 Bach Dang, Hai Chau, Da Nang',
      ),
    ],
  ),
  _PlaceSection(
    title: 'Where to Stay',
    subtitle: 'Accommodations nearby',
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
        category: 'Hotel',
        description: 'Modern 4-star hotel in the city centre with rooftop pool, spa, and stunning views of the Han River and Dragon Bridge.',
        address: '478 Tran Hung Dao, Son Tra, Da Nang',
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
        category: 'Resort',
        description: 'Beachfront 5-star resort directly on My Khe Beach. Features multiple pools, a private beach, and world-class dining.',
        address: '101 Vo Nguyen Giap, Son Tra, Da Nang',
        pricePerNight: r'$180/night',
      ),
      _Place(
        id: 'holiday-beach',
        name: 'Holiday Beach Hotel',
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=600',
        rating: 4.5,
        reviewCount: 1150,
        price: r'$$',
        hours: 'Check-in 2PM',
        distance: '2.0 km',
        latLng: LatLng(16.0580, 108.2440),
        category: 'Hotel',
        description: 'Well-located 4-star hotel one block from My Khe Beach. Outdoor pool, breakfast included, and great value for money.',
        address: '218 Vo Nguyen Giap, Son Tra, Da Nang',
        pricePerNight: r'$55/night',
      ),
      _Place(
        id: 'brilliant-hotel',
        name: 'Brilliant Hotel',
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c4a49ce5?w=600',
        rating: 4.3,
        reviewCount: 870,
        price: r'$$',
        hours: 'Check-in 3PM',
        distance: '1.5 km',
        latLng: LatLng(16.0535, 108.2222),
        category: 'Hotel',
        description: 'City-centre hotel with Han River views, rooftop bar, and convenient access to restaurants and nightlife.',
        address: '162 Bach Dang, Hai Chau, Da Nang',
        pricePerNight: r'$45/night',
      ),
    ],
  ),
];

List<_Place> get _kAllPlaces => _kSections
    .where((_PlaceSection s) => s.cardType != _SectionCardType.collectionList)
    .expand((_PlaceSection s) => s.places)
    .toList();

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// The Explore tab — Google Map with a draggable place discovery sheet.
class DiscoveryScreen extends ConsumerStatefulWidget {
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

  void _goToMyLocation() {
    HapticFeedback.lightImpact();
    final LatLng? loc = ref.read(currentLocationProvider).valueOrNull;
    if (loc != null) _mapController?.animateCamera(CameraUpdate.newLatLng(loc));
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
            initialCameraPosition: CameraPosition(target: mapCenter, zoom: 13.5),
            onMapCreated: (GoogleMapController c) => _mapController = c,
            markers: _markers,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
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

          Positioned(
            right: Responsive.w(context, 16),
            bottom: MediaQuery.sizeOf(context).height * 0.47,
            child: _MapControls(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onMyLocation: _goToMyLocation,
            ),
          ),

          Positioned.fill(child: _ExploreBottomSheet(selectedCategoryIndex: _selectedCategoryIndex)),
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

// Chip-index → section index mapping (null = "All" → home feed).
// Chip order: All(0), Restaurants(1), Hotels(2), Coffee(3), Activities(4).
// Section order in _kSections: Community(0), Eat(1), Play(2), Drink(3), Stay(4).
const List<int?> _kChipToSectionIndex = <int?>[null, 1, 4, 3, 2];

class _ExploreBottomSheet extends StatefulWidget {
  const _ExploreBottomSheet({required this.selectedCategoryIndex});

  final int selectedCategoryIndex;

  @override
  State<_ExploreBottomSheet> createState() => _ExploreBottomSheetState();
}

class _ExploreBottomSheetState extends State<_ExploreBottomSheet> {
  int _selectedTabIndex = 0;
  final Set<String> _bookmarkedIds = <String>{};
  _PlaceSection? _activeSection;
  _Place? _activePlace;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void didUpdateWidget(_ExploreBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryIndex != widget.selectedCategoryIndex) {
      final int? sectionIdx = _kChipToSectionIndex[widget.selectedCategoryIndex];
      if (sectionIdx == null) {
        setState(() { _activeSection = null; _activePlace = null; });
      } else {
        _onSeeMore(_kSections[sectionIdx]);
      }
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _onSeeMore(_PlaceSection section) {
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

  void _onPlaceTap(_Place place) {
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
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _activePlace!.name,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                        _bookmarkedIds.contains(_activePlace!.id)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        key: ValueKey<bool>(_bookmarkedIds.contains(_activePlace!.id)),
                        size: Responsive.w(context, 22),
                        color: _bookmarkedIds.contains(_activePlace!.id)
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
                    child: Icon(Icons.close_rounded, size: Responsive.w(context, 18), color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          )
        else if (_activeSection != null)
          // Drilldown header: back + section title
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
          // Home header: Explore / Saved Places tabs
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

  // ── Home feed slivers ─────────────────────────────────────────────────────

  List<Widget> _buildHomeSlivers(BuildContext context) {
    final List<Widget> slivers = <Widget>[];

    for (final _PlaceSection section in _kSections) {
      slivers.add(
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: section.title,
            subtitle: section.subtitle,
            onSeeMore: section.cardType == _SectionCardType.placeList
                ? () => _onSeeMore(section)
                : null,
          ),
        ),
      );

      slivers.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: Responsive.h(context, 220),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
              itemCount: section.cardType == _SectionCardType.collectionList
                  ? section.collections.length
                  : section.places.length,
              itemBuilder: (BuildContext ctx, int index) {
                final double cardWidth = Responsive.w(context, 160);
                final EdgeInsets itemPadding = EdgeInsets.only(right: Responsive.w(context, 12));

                if (section.cardType == _SectionCardType.collectionList) {
                  return Padding(
                    padding: itemPadding,
                    child: SizedBox(
                      width: cardWidth,
                      child: _CollectionHorizontalCard(
                        collection: section.collections[index],
                        onTap: () => HapticFeedback.lightImpact(),
                      ),
                    ),
                  );
                }

                final _Place place = section.places[index];
                return Padding(
                  padding: itemPadding,
                  child: SizedBox(
                    width: cardWidth,
                    child: _ExploreHorizontalCard(
                      place: place,
                      isBookmarked: _bookmarkedIds.contains(place.id),
                      onTap: () => _onPlaceTap(place),
                      onBookmark: () => _onBookmark(place),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      slivers.add(SliverToBoxAdapter(child: SizedBox(height: Responsive.h(context, 8))));
    }

    slivers.add(SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Responsive.h(context, 24)),
    ));

    return slivers;
  }

  // ── Drill-down slivers ────────────────────────────────────────────────────

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
          onTap: () => _onPlaceTap(place),
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

  // ── Place detail slivers ──────────────────────────────────────────────────

  List<Widget> _buildPlaceDetailSlivers(BuildContext context, _Place place) {
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
                place.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainer),
              ),
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
                    borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                  ),
                  child: Text(
                    place.category,
                    style: textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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
              Icon(Icons.star_rounded, size: Responsive.w(context, 16), color: Colors.amber),
              SizedBox(width: Responsive.w(context, 4)),
              Text(
                '${place.rating} (${_fmtCount(place.reviewCount)})',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 12)),
                child: Container(
                  width: 1,
                  height: Responsive.h(context, 14),
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              Icon(Icons.attach_money_rounded, size: Responsive.w(context, 16), color: colorScheme.onSurfaceVariant),
              Text(
                place.price,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),

      // Description
      if (place.description != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20), vertical: Responsive.h(context, 8)),
            child: Text(
              place.description!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
          ),
        ),

      // Location
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Responsive.w(context, 20), Responsive.h(context, 8), Responsive.w(context, 20), 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.location_on_outlined, size: Responsive.w(context, 16), color: colorScheme.onSurfaceVariant),
              SizedBox(width: Responsive.w(context, 8)),
              Expanded(
                child: Text(
                  place.address ?? 'Da Nang, Vietnam',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),

      // Hours
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Responsive.w(context, 20), Responsive.h(context, 6), Responsive.w(context, 20), Responsive.h(context, 16)),
          child: Row(
            children: <Widget>[
              Icon(Icons.access_time_rounded, size: Responsive.w(context, 16), color: colorScheme.onSurfaceVariant),
              SizedBox(width: Responsive.w(context, 8)),
              Text(
                place.hours,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),

      SliverToBoxAdapter(child: Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15))),

      // More photos
      SliverToBoxAdapter(child: _buildDetailSectionHeader(context, 'More photos')),
      SliverToBoxAdapter(
        child: SizedBox(
          height: Responsive.h(context, 110),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 20)),
            itemCount: 4,
            itemBuilder: (_, int i) => Padding(
              padding: EdgeInsets.only(right: Responsive.w(context, 10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
                child: Image.network(
                  place.imageUrl,
                  width: Responsive.w(context, 140),
                  height: Responsive.h(context, 110),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
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

      SliverToBoxAdapter(child: Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15))),

      // Opening hours
      SliverToBoxAdapter(child: _buildDetailSectionHeader(context, 'Opening hours')),
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

      SliverToBoxAdapter(child: Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15))),

      // Contact
      SliverToBoxAdapter(child: _buildDetailSectionHeader(context, 'Contact')),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Responsive.w(context, 20), 0, Responsive.w(context, 20), Responsive.h(context, 16)),
          child: Row(
            children: <Widget>[
              const _ContactChip(icon: Icons.call_rounded, label: 'Call'),
              SizedBox(width: Responsive.w(context, 10)),
              const _ContactChip(icon: Icons.language_rounded, label: 'Website'),
              SizedBox(width: Responsive.w(context, 10)),
              const _ContactChip(icon: Icons.map_rounded, label: 'Google Maps'),
            ],
          ),
        ),
      ),

      SliverToBoxAdapter(child: Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.15))),

      // Reviews
      SliverToBoxAdapter(
        child: _buildDetailSectionHeader(context, 'Google reviews · ${_fmtCount(place.reviewCount)}'),
      ),
      const SliverToBoxAdapter(
        child: _ReviewCard(
          avatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
          name: 'Chris L.',
          daysAgo: '4 days ago',
          stars: 5,
          review: 'Absolutely wonderful experience! A must-visit when you\'re in Da Nang.',
        ),
      ),
      SliverToBoxAdapter(child: Divider(height: 1, indent: Responsive.w(context, 20), endIndent: Responsive.w(context, 20))),
      const SliverToBoxAdapter(
        child: _ReviewCard(
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          name: 'Ken G.',
          daysAgo: '1 month ago',
          stars: 5,
          review: 'Iconic landmark. Best experienced in the evening when the lights come on.',
        ),
      ),

      SliverToBoxAdapter(
        child: SizedBox(height: MediaQuery.paddingOf(context).bottom + Responsive.h(context, 32)),
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHoursRow(BuildContext context, String day, String time) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(day, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        Text(time, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final _PlaceSection? activeSection = _activeSection;
    final _Place? activePlace = _activePlace;

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
                    activePlace?.id ?? (activeSection != null ? 'drill:${activeSection.title}' : 'home'),
                  ),
                  controller: scrollController,
                  slivers: activePlace != null
                      ? _buildPlaceDetailSlivers(context, activePlace)
                      : activeSection != null
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

  String _fmtCount(int count) => count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';
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
// Horizontal card — places
// ---------------------------------------------------------------------------

class _ExploreHorizontalCard extends StatelessWidget {
  const _ExploreHorizontalCard({
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
                    child: Image.network(
                      place.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainer),
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
// Horizontal card — collections
// ---------------------------------------------------------------------------

class _CollectionHorizontalCard extends StatelessWidget {
  const _CollectionHorizontalCard({required this.collection, required this.onTap});

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
                    child: Image.network(
                      collection.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainer),
                    ),
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
                        child: Image.network(
                          collection.authorAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.brandGradientStart,
                            child: Icon(Icons.person_rounded, color: Colors.white, size: Responsive.w(context, 16)),
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
// List card — drill-down view
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
            Icon(icon, size: Responsive.w(context, 14), color: AppColors.brandGradientStart),
            SizedBox(width: Responsive.w(context, 6)),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
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
              errorBuilder: (_, __, ___) => Container(
                width: Responsive.w(context, 40),
                height: Responsive.w(context, 40),
                color: colorScheme.surfaceContainer,
                child: Icon(Icons.person_rounded, size: Responsive.w(context, 22), color: colorScheme.onSurfaceVariant),
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
                      child: Text(name, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Text(daysAgo, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
                SizedBox(height: Responsive.h(context, 4)),
                Row(
                  children: List<Widget>.generate(
                    5,
                    (int i) => Icon(
                      Icons.star_rounded,
                      size: Responsive.w(context, 14),
                      color: i < stars ? Colors.amber : colorScheme.outline.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 6)),
                Text(
                  review,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
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
