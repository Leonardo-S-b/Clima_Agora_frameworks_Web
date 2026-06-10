import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../models/route_tracking.dart';
import '../providers/route_tracking_provider.dart';

class RouteMapWidget extends ConsumerWidget {
  const RouteMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routeTrackingProvider);
    final center = _resolveCenter(state);
    final routePoints = _buildRoutePoints(state);
    final markers = _buildMarkers(state);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 10,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.clima_agora',
            ),
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: Colors.lightBlueAccent,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'OpenStreetMap contributors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  osm.LatLng _resolveCenter(RouteTrackingState? state) {
    if (state == null) {
      return const osm.LatLng(-23.55052, -46.633308);
    }

    if (state.routePoints.isNotEmpty) {
      final avgLat = state.routePoints
              .map((point) => point.latitude)
              .reduce((a, b) => a + b) /
          state.routePoints.length;
      final avgLng = state.routePoints
              .map((point) => point.longitude)
              .reduce((a, b) => a + b) /
          state.routePoints.length;
      return osm.LatLng(avgLat, avgLng);
    }

    return osm.LatLng(state.userPosition.latitude, state.userPosition.longitude);
  }

  List<osm.LatLng> _buildRoutePoints(RouteTrackingState? state) {
    if (state == null) {
      return const [];
    }

    return state.routePoints
        .map((point) => osm.LatLng(point.latitude, point.longitude))
        .toList(growable: false);
  }

  List<Marker> _buildMarkers(RouteTrackingState? state) {
    if (state == null) {
      return const [];
    }

    final markers = <Marker>[
      Marker(
        point: osm.LatLng(state.userPosition.latitude, state.userPosition.longitude),
        width: 48,
        height: 48,
        child: _MarkerChip(
          color: Colors.blueAccent,
          icon: Icons.navigation_rounded,
          label: 'Voce',
        ),
      ),
    ];

    for (final point in state.intermediatePoints) {
      markers.add(
        Marker(
          point: osm.LatLng(point.coordinates.latitude, point.coordinates.longitude),
          width: 76,
          height: 76,
          child: _WeatherMarker(point: point),
        ),
      );
    }

    return markers;
  }
}

class _WeatherMarker extends StatelessWidget {
  const _WeatherMarker({required this.point});

  final IntermediatePoint point;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _weatherStyle(point.weather.condition);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MarkerChip(
          color: color,
          icon: icon,
          label: '${point.weather.temperature.toStringAsFixed(0)}C',
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            point.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  (Color, IconData) _weatherStyle(String condition) {
    return switch (condition) {
      'sunny' => (Colors.orangeAccent, Icons.wb_sunny_rounded),
      'cloudy' => (Colors.blueGrey, Icons.cloud_rounded),
      'rainy' => (Colors.lightBlueAccent, Icons.umbrella_rounded),
      'stormy' => (Colors.redAccent, Icons.thunderstorm_rounded),
      'foggy' => (Colors.blueGrey, Icons.cloud_rounded),
      'snowy' => (Colors.lightBlue, Icons.ac_unit_rounded),
      _ => (Colors.tealAccent, Icons.pin_drop_rounded),
    };
  }
}

class _MarkerChip extends StatelessWidget {
  const _MarkerChip({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
