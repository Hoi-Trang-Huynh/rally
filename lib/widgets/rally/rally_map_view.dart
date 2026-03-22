import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A Google Map view for the rally overview screen.
///
/// Displays a full-size Google Map. Currently shows an empty map
/// centered on a default position. In the future, this will display
/// event markers when the events API is available.
class RallyMapView extends StatefulWidget {
  /// Optional initial camera target.
  final LatLng? initialTarget;

  /// Optional initial zoom level. Defaults to 12.
  final double initialZoom;

  /// Creates a new [RallyMapView].
  const RallyMapView({super.key, this.initialTarget, this.initialZoom = 12.0});

  @override
  State<RallyMapView> createState() => _RallyMapViewState();
}

class _RallyMapViewState extends State<RallyMapView> {
  GoogleMapController? _controller;

  static const LatLng _defaultTarget = LatLng(10.7769, 106.7009); // Ho Chi Minh City

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LatLng target = widget.initialTarget ?? _defaultTarget;

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target, zoom: widget.initialZoom),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
