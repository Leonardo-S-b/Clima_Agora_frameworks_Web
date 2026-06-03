import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/route_tracking_provider.dart';

class RouteMapWidget extends ConsumerStatefulWidget {
  const RouteMapWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends ConsumerState<RouteMapWidget> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routeTrackingProvider);
    final initial = state?.userPosition ?? const LatLng(-23.55052, -46.633308);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initial, zoom: 12),
      markers: _buildMarkers(state),
      polylines: _buildPolylines(state),
      onMapCreated: (c) => _controller = c,
    );
  }

  Set<Marker> _buildMarkers(state) {
    final markers = <Marker>{};
    if (state == null) return markers;
    markers.add(Marker(markerId: const MarkerId('user'), position: state.userPosition));
    for (var p in state.intermediatePoints) {
      markers.add(Marker(markerId: MarkerId('pt_${p.index}'), position: p.coordinates));
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(state) {
    if (state == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: state.routePoints,
        color: Colors.blue,
        width: 4,
      )
    };
  }
}
