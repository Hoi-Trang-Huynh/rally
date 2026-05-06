import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A place returned from the backend's Google Places proxy.
class PlaceResult {
  /// Creates a [PlaceResult].
  const PlaceResult({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.priceLevel,
    this.description,
    this.address,
    this.hours,
    this.openNow,
    this.type,
    this.distance,
    this.pricePerNight,
  });

  /// Google Place ID.
  final String id;

  /// Display name of the place.
  final String name;

  /// Latitude coordinate.
  final double lat;

  /// Longitude coordinate.
  final double lng;

  /// Resolved photo URL provided by the backend.
  final String? imageUrl;

  /// Average star rating (1–5).
  final double? rating;

  /// Total number of user reviews.
  final int? reviewCount;

  /// Price level, e.g. "\$", "\$\$", "\$\$\$".
  final String? priceLevel;

  /// Short description or editorial summary.
  final String? description;

  /// Formatted address.
  final String? address;

  /// Human-readable opening hours summary, e.g. "7AM–10PM".
  final String? hours;

  /// Whether the place is currently open.
  final bool? openNow;

  /// Google Places type, e.g. "restaurant", "lodging".
  final String? type;

  /// Human-readable distance from the search centre, e.g. "1.2 km".
  final String? distance;

  /// Nightly rate string for lodging, e.g. "\$80/night".
  final String? pricePerNight;

  /// Convenience getter for a [LatLng] from [lat]/[lng].
  LatLng get latLng => LatLng(lat, lng);

  /// Deserialises a [PlaceResult] from a backend JSON map.
  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      priceLevel: json['priceLevel'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      hours: json['hours'] as String?,
      openNow: json['openNow'] as bool?,
      type: json['type'] as String?,
      distance: json['distance'] as String?,
      pricePerNight: json['pricePerNight'] as String?,
    );
  }

  /// Serialises this instance to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (rating != null) 'rating': rating,
        if (reviewCount != null) 'reviewCount': reviewCount,
        if (priceLevel != null) 'priceLevel': priceLevel,
        if (description != null) 'description': description,
        if (address != null) 'address': address,
        if (hours != null) 'hours': hours,
        if (openNow != null) 'openNow': openNow,
        if (type != null) 'type': type,
        if (distance != null) 'distance': distance,
        if (pricePerNight != null) 'pricePerNight': pricePerNight,
      };

  @override
  bool operator ==(Object other) => other is PlaceResult && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
