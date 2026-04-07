import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class RouteLegResult {
  final double distanceKm;
  final Duration duration;

  const RouteLegResult({required this.distanceKm, required this.duration});
}

class OpenRouteServiceApi {
  final http.Client _client;
  final String _apiKey;

  OpenRouteServiceApi(this._client)
    : _apiKey = const String.fromEnvironment('ORS_API_KEY');

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<List<RouteLegResult>> getDrivingLegs({
    required double originLat,
    required double originLon,
    required List<Map<String, double>> points,
  }) async {
    if (points.isEmpty) return const [];

    if (!isConfigured) {
      return _buildEstimatedLegs(
        originLat: originLat,
        originLon: originLon,
        points: points,
      );
    }

    final coordinates = <List<double>>[
      [originLon, originLat],
      ...points.map((point) => [point['lon']!, point['lat']!]),
    ];

    final uri = Uri.https(
      'api.openrouteservice.org',
      '/v2/directions/driving-car/json',
    );

    final res = await _client.post(
      uri,
      headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'coordinates': coordinates}),
    );

    if (res.statusCode != 200) {
      return _buildEstimatedLegs(
        originLat: originLat,
        originLon: originLon,
        points: points,
      );
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final routes = (body['routes'] as List?) ?? const [];
    if (routes.isEmpty) {
      return _buildEstimatedLegs(
        originLat: originLat,
        originLon: originLon,
        points: points,
      );
    }

    final firstRoute = routes.first as Map<String, dynamic>;
    final segments = (firstRoute['segments'] as List?) ?? const [];
    if (segments.isEmpty) {
      return _buildEstimatedLegs(
        originLat: originLat,
        originLon: originLon,
        points: points,
      );
    }

    return segments
        .map((segment) {
          final map = segment as Map<String, dynamic>;
          final distanceMeters = (map['distance'] as num?)?.toDouble() ?? 0;
          final durationSeconds = (map['duration'] as num?)?.toDouble() ?? 0;
          return RouteLegResult(
            distanceKm: distanceMeters / 1000,
            duration: Duration(seconds: durationSeconds.round()),
          );
        })
        .toList(growable: false);
  }

  List<RouteLegResult> _buildEstimatedLegs({
    required double originLat,
    required double originLon,
    required List<Map<String, double>> points,
  }) {
    const averageSpeedKmh = 70.0;
    final results = <RouteLegResult>[];

    var fromLat = originLat;
    var fromLon = originLon;

    for (final point in points) {
      final toLat = point['lat']!;
      final toLon = point['lon']!;
      final distanceKm = _haversineKm(fromLat, fromLon, toLat, toLon);
      final durationHours = distanceKm / averageSpeedKmh;
      final duration = Duration(minutes: (durationHours * 60).round());

      results.add(RouteLegResult(distanceKm: distanceKm, duration: duration));
      fromLat = toLat;
      fromLon = toLon;
    }

    return results;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  void dispose() {
    _client.close();
  }
}
