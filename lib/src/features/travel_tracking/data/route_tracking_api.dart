import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_tracking.dart';

class RouteTrackingPlan {
  const RouteTrackingPlan({
    required this.routePoints,
    required this.intermediatePoints,
    required this.originWeather,
    required this.destinationWeather,
    required this.totalDistanceKm,
    required this.estimatedDuration,
  });

  final List<LatLng> routePoints;
  final List<IntermediatePoint> intermediatePoints;
  final WeatherSnapshot originWeather;
  final WeatherSnapshot destinationWeather;
  final double totalDistanceKm;
  final Duration estimatedDuration;
}

class RouteTrackingApi {
  RouteTrackingApi(this._client);

  static const _backendUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'http://localhost:8787',
  );

  final http.Client _client;

  Future<RouteTrackingPlan> planRoute({
    required LatLng origin,
    required List<LatLng> stops,
    int weatherPointCount = 7,
  }) async {
    final uri = Uri.parse('$_backendUrl/travel/route-tracking/plan');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'origin': _pointToJson(origin),
        'stops': stops.map(_pointToJson).toList(growable: false),
        'mode': 'driving',
        'weatherPointCount': weatherPointCount,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Falha ao calcular rota real: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return RouteTrackingPlan(
      routePoints: _parseRoutePoints(json['routePoints']),
      intermediatePoints: _parseIntermediatePoints(json['intermediatePoints']),
      originWeather: _parseWeather(json['originWeather']),
      destinationWeather: _parseWeather(json['destinationWeather']),
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      estimatedDuration: Duration(
        seconds: (json['estimatedDurationSeconds'] as num?)?.round() ?? 0,
      ),
    );
  }

  Map<String, double> _pointToJson(LatLng point) {
    return {'lat': point.latitude, 'lng': point.longitude};
  }

  List<LatLng> _parseRoutePoints(dynamic value) {
    final items = (value as List?) ?? const [];
    return items
        .map((item) {
          final map = item as Map<String, dynamic>;
          return LatLng(
            (map['lat'] as num).toDouble(),
            (map['lng'] as num).toDouble(),
          );
        })
        .toList(growable: false);
  }

  List<IntermediatePoint> _parseIntermediatePoints(dynamic value) {
    final items = (value as List?) ?? const [];
    return items
        .map((item) {
          final map = item as Map<String, dynamic>;
          final estimatedTime =
              map['estimatedTimeToReach'] as Map<String, dynamic>?;

          return IntermediatePoint(
            index: (map['index'] as num?)?.toInt() ?? 0,
            coordinates: LatLng(
              (map['lat'] as num).toDouble(),
              (map['lng'] as num).toDouble(),
            ),
            label: (map['label'] as String?)?.trim() ?? 'Ponto do trajeto',
            weather: _parseWeather(map['weather']),
            distanceFromStart:
                (map['distanceFromStart'] as num?)?.toDouble() ?? 0,
            estimatedTimeToReach: Duration(
              seconds: (estimatedTime?['inSeconds'] as num?)?.round() ?? 0,
            ),
          );
        })
        .toList(growable: false);
  }

  WeatherSnapshot _parseWeather(dynamic value) {
    final map = (value as Map?)?.cast<String, dynamic>() ?? const {};
    return WeatherSnapshot(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (map['humidity'] as num?)?.round() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0,
      rainChance: (map['rainChance'] as num?)?.round() ?? 0,
      condition: (map['condition'] as String?)?.trim() ?? 'unknown',
      temperatureTrend: _parseTemperatureTrend(map['temperatureTrend']),
      fetchedAt:
          DateTime.tryParse((map['fetchedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  TemperatureTrend? _parseTemperatureTrend(dynamic value) {
    final map = (value as Map?)?.cast<String, dynamic>();
    if (map == null) {
      return null;
    }

    return TemperatureTrend(
      next3h: (map['next3h'] as num?)?.toDouble() ?? 0,
      direction: (map['direction'] as String?)?.trim() ?? 'stable',
      minNext6h: (map['minNext6h'] as num?)?.toDouble() ?? 0,
    );
  }
}
