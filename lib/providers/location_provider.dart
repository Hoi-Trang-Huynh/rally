import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Resolves the device's current GPS position, or null if permission is denied.
final FutureProvider<LatLng?> currentLocationProvider =
    FutureProvider<LatLng?>((Ref ref) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    return null;
  }
  final Position pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
  return LatLng(pos.latitude, pos.longitude);
});
