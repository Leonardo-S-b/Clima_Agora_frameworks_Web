import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../models/route_tracking.dart';
import '../providers/route_tracking_provider.dart';

class RouteMapWidget extends ConsumerStatefulWidget {
  const RouteMapWidget({
    super.key,
    this.onExpand,
    this.onToggleTracking,
    this.compact = false,
    this.fullscreen = false,
  });

  final VoidCallback? onExpand;
  final VoidCallback? onToggleTracking;
  final bool compact;
  final bool fullscreen;

  @override
  ConsumerState<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends ConsumerState<RouteMapWidget> {
  int? _selectedPointIndex;
  bool _radarEnabled = false;
  Future<_RainViewerFrame?>? _radarFrameFuture;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(routeTrackingProvider);
    final center = _resolveCenter(state);
    final routePoints = _buildRoutePoints(state);
    final markers = _buildMarkers(state);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: widget.compact ? 8.5 : 10,
            onTap: (_, tapPosition) =>
                setState(() => _selectedPointIndex = null),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.clima_agora',
            ),
            if (_radarEnabled)
              FutureBuilder<_RainViewerFrame?>(
                future: _radarFrameFuture,
                builder: (context, snapshot) {
                  final frame = snapshot.data;
                  if (frame == null) {
                    return const SizedBox.shrink();
                  }

                  return TileLayer(
                    urlTemplate:
                        '${frame.host}${frame.path}/512/{z}/{x}/{y}/2/1_1.png',
                    userAgentPackageName: 'com.example.clima_agora',
                    maxNativeZoom: 7,
                    tileDisplay: const TileDisplay.fadeIn(),
                    tileBuilder: (context, tileWidget, tile) =>
                        Opacity(opacity: 0.62, child: tileWidget),
                  );
                },
              ),
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: widget.compact ? 4 : 5,
                    color: const Color(0xFF22B8E8),
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        ),
        if (state != null) _RouteHud(state: state, compact: widget.compact),
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MapIconButton(
                icon: _radarEnabled
                    ? Icons.radar_rounded
                    : Icons.radar_outlined,
                tooltip: _radarEnabled ? 'Ocultar radar' : 'Mostrar radar',
                selected: _radarEnabled,
                onPressed: _toggleRadar,
              ),
              const SizedBox(height: 8),
              _MapIconButton(
                icon: widget.fullscreen
                    ? Icons.close_fullscreen_rounded
                    : Icons.open_in_full_rounded,
                tooltip: widget.fullscreen ? 'Recolher mapa' : 'Expandir mapa',
                onPressed: _handleExpand,
              ),
              if (widget.onToggleTracking != null) ...[
                const SizedBox(height: 8),
                _MapIconButton(
                  icon: state?.isTracking == true
                      ? Icons.pause_circle_outline
                      : Icons.my_location,
                  tooltip: state?.isTracking == true
                      ? 'Pausar GPS'
                      : 'Acompanhar com GPS',
                  onPressed: widget.onToggleTracking,
                ),
              ],
            ],
          ),
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

  void _toggleRadar() {
    setState(() {
      _radarEnabled = !_radarEnabled;
      if (_radarEnabled) {
        _radarFrameFuture ??= _RainViewerFrame.fetchLatest();
      }
    });
  }

  void _handleExpand() {
    if (widget.onExpand != null) {
      widget.onExpand!();
      return;
    }

    if (widget.fullscreen) {
      Navigator.of(context).maybePop();
      return;
    }

    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (context) => Dialog.fullscreen(
        child: SafeArea(
          child: RouteMapWidget(
            compact: false,
            fullscreen: true,
            onExpand: () => Navigator.of(context).maybePop(),
            onToggleTracking: widget.onToggleTracking,
          ),
        ),
      ),
    );
  }

  osm.LatLng _resolveCenter(RouteTrackingState? state) {
    if (state == null) {
      return const osm.LatLng(-23.55052, -46.633308);
    }

    if (state.routePoints.isNotEmpty) {
      final avgLat =
          state.routePoints
              .map((point) => point.latitude)
              .reduce((a, b) => a + b) /
          state.routePoints.length;
      final avgLng =
          state.routePoints
              .map((point) => point.longitude)
              .reduce((a, b) => a + b) /
          state.routePoints.length;
      return osm.LatLng(avgLat, avgLng);
    }

    return osm.LatLng(
      state.userPosition.latitude,
      state.userPosition.longitude,
    );
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
        point: osm.LatLng(
          state.userPosition.latitude,
          state.userPosition.longitude,
        ),
        width: 56,
        height: 56,
        child: const _MarkerChip(
          color: Colors.blueAccent,
          icon: Icons.navigation_rounded,
          label: 'Voce',
        ),
      ),
    ];

    for (final point in state.intermediatePoints) {
      final selected = _selectedPointIndex == point.index;
      markers.add(
        Marker(
          point: osm.LatLng(
            point.coordinates.latitude,
            point.coordinates.longitude,
          ),
          width: selected ? 222 : 92,
          height: selected ? 164 : 86,
          alignment: Alignment.topCenter,
          child: _WeatherMarker(
            point: point,
            selected: selected,
            onTap: () {
              setState(() {
                _selectedPointIndex = _selectedPointIndex == point.index
                    ? null
                    : point.index;
              });
            },
          ),
        ),
      );
    }

    return markers;
  }
}

class _RainViewerFrame {
  const _RainViewerFrame({required this.host, required this.path});

  final String host;
  final String path;

  static Future<_RainViewerFrame?> fetchLatest() async {
    final response = await http.get(
      Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final host = (data['host'] as String?)?.trim();
    final radar = data['radar'] as Map<String, dynamic>?;
    final past = radar?['past'] as List<dynamic>?;
    if (host == null || host.isEmpty || past == null || past.isEmpty) {
      return null;
    }

    final latest = past.last as Map<String, dynamic>;
    final path = (latest['path'] as String?)?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }

    return _RainViewerFrame(host: host, path: path);
  }
}

class _RouteHud extends StatelessWidget {
  const _RouteHud({required this.state, required this.compact});

  final RouteTrackingState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10,
      top: 10,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? 222 : 270),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF17212B).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.route_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.progress.totalDistanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${state.progress.percentComplete.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                LinearProgressIndicator(
                  value: (state.progress.percentComplete / 100).clamp(0, 1),
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  color: const Color(0xFF67E8F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.cloud_queue_rounded,
                      color: Colors.white.withValues(alpha: 0.72),
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${state.intermediatePoints.length} pontos climaticos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherMarker extends StatelessWidget {
  const _WeatherMarker({
    required this.point,
    required this.selected,
    required this.onTap,
  });

  final IntermediatePoint point;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _weatherStyle(point.weather.condition);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(selected ? 10 : 999),
        child: selected
            ? _WeatherDetailsCard(point: point, color: color, icon: icon)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MarkerChip(
                    color: color,
                    icon: icon,
                    label: '${point.weather.temperature.toStringAsFixed(0)}C',
                  ),
                  const SizedBox(height: 2),
                  _PointLabel(label: point.label),
                ],
              ),
      ),
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

class _WeatherDetailsCard extends StatelessWidget {
  const _WeatherDetailsCard({
    required this.point,
    required this.color,
    required this.icon,
  });

  final IntermediatePoint point;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF17212B).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 17),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${point.weather.temperature.toStringAsFixed(0)}C agora',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.74),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _WeatherMetricChip(
                    icon: Icons.water_drop_outlined,
                    label: '${point.weather.humidity}%',
                  ),
                  _WeatherMetricChip(
                    icon: Icons.grain_rounded,
                    label: '${point.weather.rainChance}%',
                  ),
                  _WeatherMetricChip(
                    icon: Icons.air_rounded,
                    label: '${point.weather.windSpeed.toStringAsFixed(0)} km/h',
                  ),
                  _WeatherMetricChip(
                    icon: Icons.near_me_outlined,
                    label: '${point.distanceFromStart.toStringAsFixed(0)} km',
                  ),
                ],
              ),
              if (point.suggestedActivities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  point.suggestedActivities.first.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherMetricChip extends StatelessWidget {
  const _WeatherMetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.76), size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointLabel extends StatelessWidget {
  const _PointLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected
            ? const Color(0xFF2563EB).withValues(alpha: 0.88)
            : Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
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
