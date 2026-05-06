import 'package:rally/models/place_result.dart';
import 'package:rally/services/api_client.dart';

/// Repository for the backend Google Places proxy endpoints.
class PlacesRepository {
  /// Creates a [PlacesRepository].
  PlacesRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Set to `true` to return placeholder data instead of calling the API.
  static const bool usePlaceholder = true;

  /// Returns places near [lat]/[lng] of the given Google Places [type].
  Future<List<PlaceResult>> nearbySearch(
    double lat,
    double lng,
    String type, {
    int maxCount = 10,
  }) async {
    if (usePlaceholder) {
      return _placeholderPlaces
          .where((PlaceResult p) => p.type == type)
          .take(maxCount)
          .toList();
    }

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

  /// Returns full details for a single place by its Google Place ID.
  Future<PlaceResult> getPlaceDetails(String placeId) async {
    if (usePlaceholder) {
      return _placeholderPlaces.firstWhere(
        (PlaceResult p) => p.id == placeId,
        orElse: () => _placeholderPlaces.first,
      );
    }

    final dynamic response = await _apiClient.get('/api/v1/places/$placeId');
    return PlaceResult.fromJson(response as Map<String, dynamic>);
  }
}

const List<PlaceResult> _placeholderPlaces = <PlaceResult>[
  // tourist_attraction
  PlaceResult(
    id: 'placeholder_ta_1',
    name: 'Notre-Dame Cathedral Basilica',
    lat: 10.7797,
    lng: 106.6990,
    type: 'tourist_attraction',
    rating: 4.6,
    reviewCount: 12480,
    description: 'Iconic 19th-century French colonial cathedral in the heart of the city.',
    address: 'Công xã Paris, Bến Nghé, Quận 1, TP.HCM',
    hours: '8AM – 5PM',
    openNow: true,
    distance: '0.4 km',
  ),
  PlaceResult(
    id: 'placeholder_ta_2',
    name: 'Reunification Palace',
    lat: 10.7771,
    lng: 106.6956,
    type: 'tourist_attraction',
    rating: 4.5,
    reviewCount: 9320,
    description: 'Historic presidential palace where the Vietnam War officially ended in 1975.',
    address: '135 Nam Kỳ Khởi Nghĩa, Bến Thành, Quận 1, TP.HCM',
    hours: '7:30AM – 5PM',
    openNow: true,
    distance: '0.8 km',
  ),
  PlaceResult(
    id: 'placeholder_ta_3',
    name: 'War Remnants Museum',
    lat: 10.7794,
    lng: 106.6919,
    type: 'tourist_attraction',
    rating: 4.7,
    reviewCount: 21050,
    description: 'Powerful museum documenting the Vietnam War through photographs and artefacts.',
    address: '28 Võ Văn Tần, Phường 6, Quận 3, TP.HCM',
    hours: '7:30AM – 6PM',
    openNow: true,
    distance: '1.2 km',
  ),
  PlaceResult(
    id: 'placeholder_ta_4',
    name: 'Ben Thanh Market',
    lat: 10.7721,
    lng: 106.6981,
    type: 'tourist_attraction',
    rating: 4.2,
    reviewCount: 34100,
    description: 'Bustling landmark market selling street food, souvenirs, and local goods.',
    address: 'Lê Lợi, Bến Thành, Quận 1, TP.HCM',
    hours: '6AM – 6PM',
    openNow: true,
    distance: '0.6 km',
  ),
  PlaceResult(
    id: 'placeholder_ta_5',
    name: 'Saigon Central Post Office',
    lat: 10.7798,
    lng: 106.6998,
    type: 'tourist_attraction',
    rating: 4.5,
    reviewCount: 8760,
    description: 'Stunning French colonial post office designed by Gustave Eiffel.',
    address: '2 Công xã Paris, Bến Nghé, Quận 1, TP.HCM',
    hours: '7AM – 7PM',
    openNow: true,
    distance: '0.5 km',
  ),

  // restaurant
  PlaceResult(
    id: 'placeholder_rs_1',
    name: 'Pho 24',
    lat: 10.7749,
    lng: 106.7019,
    type: 'restaurant',
    rating: 4.3,
    reviewCount: 5640,
    priceLevel: r'$',
    description: 'Popular chain serving classic Vietnamese pho in a clean, air-conditioned setting.',
    address: '5 Nguyễn Thiệp, Bến Nghé, Quận 1, TP.HCM',
    hours: '6AM – 10PM',
    openNow: true,
    distance: '0.3 km',
  ),
  PlaceResult(
    id: 'placeholder_rs_2',
    name: 'The Deck Saigon',
    lat: 10.8031,
    lng: 106.7305,
    type: 'restaurant',
    rating: 4.5,
    reviewCount: 2890,
    priceLevel: r'$$$',
    description: 'Riverside restaurant with stunning views and an eclectic international menu.',
    address: '38 Nguyễn U Dĩ, Thảo Điền, Quận 2, TP.HCM',
    hours: '11AM – 11PM',
    openNow: true,
    distance: '4.1 km',
  ),
  PlaceResult(
    id: 'placeholder_rs_3',
    name: 'Cục Gạch Quán',
    lat: 10.7839,
    lng: 106.6945,
    type: 'restaurant',
    rating: 4.6,
    reviewCount: 4120,
    priceLevel: r'$$',
    description: 'Charming heritage house restaurant serving authentic Vietnamese home-cooking.',
    address: '10 Đặng Tất, Tân Định, Quận 1, TP.HCM',
    hours: '11AM – 10PM',
    openNow: true,
    distance: '1.5 km',
  ),
  PlaceResult(
    id: 'placeholder_rs_4',
    name: 'Nhà Hàng Ngon',
    lat: 10.7779,
    lng: 106.6939,
    type: 'restaurant',
    rating: 4.4,
    reviewCount: 7830,
    priceLevel: r'$$',
    description: 'Garden restaurant with live street-food stalls covering every Vietnamese region.',
    address: '160 Pasteur, Bến Nghé, Quận 1, TP.HCM',
    hours: '7AM – 10PM',
    openNow: true,
    distance: '0.9 km',
  ),
  PlaceResult(
    id: 'placeholder_rs_5',
    name: 'Bun Bo Hue An Nam',
    lat: 10.7701,
    lng: 106.6935,
    type: 'restaurant',
    rating: 4.4,
    reviewCount: 3210,
    priceLevel: r'$',
    description: 'Beloved local spot for spicy Hue-style beef noodle soup.',
    address: '14 Tôn Thất Tùng, Phạm Ngũ Lão, Quận 1, TP.HCM',
    hours: '6AM – 2PM',
    openNow: false,
    distance: '1.1 km',
  ),

  // amusement_park
  PlaceResult(
    id: 'placeholder_ap_1',
    name: 'Dam Sen Water Park',
    lat: 10.7554,
    lng: 106.6472,
    type: 'amusement_park',
    rating: 4.1,
    reviewCount: 18200,
    priceLevel: r'$$',
    description: 'Large water park with slides, wave pools, and family attractions.',
    address: '3 Hòa Bình, Phường 3, Quận 11, TP.HCM',
    hours: '8AM – 6PM',
    openNow: true,
    distance: '5.8 km',
  ),
  PlaceResult(
    id: 'placeholder_ap_2',
    name: 'Suoi Tien Theme Park',
    lat: 10.8623,
    lng: 106.8337,
    type: 'amusement_park',
    rating: 4.0,
    reviewCount: 22400,
    priceLevel: r'$$',
    description: 'Vast cultural theme park blending Vietnamese folklore with rides and water attractions.',
    address: 'Xa lộ Hà Nội, Hiệp Phú, Quận 9, TP.HCM',
    hours: '8AM – 6PM',
    openNow: true,
    distance: '14.2 km',
  ),
  PlaceResult(
    id: 'placeholder_ap_3',
    name: 'VinKE Times City',
    lat: 10.7735,
    lng: 106.6593,
    type: 'amusement_park',
    rating: 4.3,
    reviewCount: 6700,
    priceLevel: r'$$$',
    description: 'Indoor entertainment complex with interactive science exhibits for children.',
    address: '458 Minh Khai, Quận 11, TP.HCM',
    hours: '9AM – 9PM',
    openNow: true,
    distance: '3.5 km',
  ),

  // bar
  PlaceResult(
    id: 'placeholder_br_1',
    name: 'Chill Skybar',
    lat: 10.7748,
    lng: 106.7028,
    type: 'bar',
    rating: 4.3,
    reviewCount: 6540,
    priceLevel: r'$$$',
    description: 'Rooftop bar on the 26th floor with panoramic city views and craft cocktails.',
    address: 'AB Tower, 76A Lê Lai, Bến Thành, Quận 1, TP.HCM',
    hours: '5PM – 2AM',
    openNow: true,
    distance: '0.4 km',
  ),
  PlaceResult(
    id: 'placeholder_br_2',
    name: 'The Observatory',
    lat: 10.7679,
    lng: 106.6971,
    type: 'bar',
    rating: 4.5,
    reviewCount: 3120,
    priceLevel: r'$$',
    description: 'Intimate craft beer and cocktail bar with a curated vinyl music experience.',
    address: '5 Nguyễn Siêu, Bến Nghé, Quận 1, TP.HCM',
    hours: '6PM – 2AM',
    openNow: false,
    distance: '1.4 km',
  ),
  PlaceResult(
    id: 'placeholder_br_3',
    name: 'EON Heli Bar',
    lat: 10.7729,
    lng: 106.7034,
    type: 'bar',
    rating: 4.4,
    reviewCount: 4880,
    priceLevel: r'$$$',
    description: 'Upscale helipad bar atop the Bitexco Tower with 360° views of the city.',
    address: '2 Hải Triều, Bến Nghé, Quận 1, TP.HCM',
    hours: '11AM – 1AM',
    openNow: true,
    distance: '0.7 km',
  ),
  PlaceResult(
    id: 'placeholder_br_4',
    name: 'Pasteur Street Brewing Co.',
    lat: 10.7771,
    lng: 106.6981,
    type: 'bar',
    rating: 4.5,
    reviewCount: 5980,
    priceLevel: r'$$',
    description: 'Pioneer craft brewery offering bold Vietnamese-ingredient beers on tap.',
    address: '144 Pasteur, Bến Nghé, Quận 1, TP.HCM',
    hours: '11AM – 11:30PM',
    openNow: true,
    distance: '0.9 km',
  ),

  // lodging
  PlaceResult(
    id: 'placeholder_lg_1',
    name: 'Park Hyatt Saigon',
    lat: 10.7772,
    lng: 106.7025,
    type: 'lodging',
    rating: 4.8,
    reviewCount: 4230,
    priceLevel: r'$$$$',
    pricePerNight: r'$320/night',
    description: 'Elegant colonial-style luxury hotel on Lam Son Square with world-class dining.',
    address: '2 Lam Sơn Square, Bến Nghé, Quận 1, TP.HCM',
    hours: 'Open 24 hours',
    openNow: true,
    distance: '0.5 km',
  ),
  PlaceResult(
    id: 'placeholder_lg_2',
    name: 'The Myst Dong Khoi',
    lat: 10.7783,
    lng: 106.7011,
    type: 'lodging',
    rating: 4.6,
    reviewCount: 2870,
    priceLevel: r'$$$',
    pricePerNight: r'$150/night',
    description: 'Boutique heritage hotel housed in a restored 1930s French colonial building.',
    address: '6-8 Hồ Huấn Nghiệp, Bến Nghé, Quận 1, TP.HCM',
    hours: 'Open 24 hours',
    openNow: true,
    distance: '0.6 km',
  ),
  PlaceResult(
    id: 'placeholder_lg_3',
    name: 'Caravelle Saigon',
    lat: 10.7762,
    lng: 106.7020,
    type: 'lodging',
    rating: 4.7,
    reviewCount: 5610,
    priceLevel: r'$$$$',
    pricePerNight: r'$210/night',
    description: 'Iconic 5-star hotel with a rich history and the legendary Saigon Saigon Rooftop Bar.',
    address: '19-23 Lam Sơn Square, Bến Nghé, Quận 1, TP.HCM',
    hours: 'Open 24 hours',
    openNow: true,
    distance: '0.4 km',
  ),
  PlaceResult(
    id: 'placeholder_lg_4',
    name: 'Bui Vien Boutique Hostel',
    lat: 10.7669,
    lng: 106.6937,
    type: 'lodging',
    rating: 4.3,
    reviewCount: 1890,
    priceLevel: r'$',
    pricePerNight: r'$18/night',
    description: 'Lively backpacker hostel in the heart of the Bui Vien walking street area.',
    address: '245 Đề Thám, Phạm Ngũ Lão, Quận 1, TP.HCM',
    hours: 'Open 24 hours',
    openNow: true,
    distance: '1.8 km',
  ),
];
