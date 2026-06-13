import 'package:latlong2/latlong.dart';

class RouteTrackingState {
  const RouteTrackingState({
    required this.userPosition,
    required this.routePoints,
    required this.intermediatePoints,
    required this.progress,
    required this.isTracking,
    required this.startedAt,
  });

  final LatLng userPosition;
  final List<LatLng> routePoints;
  final List<IntermediatePoint> intermediatePoints;
  final RouteProgress progress;
  final bool isTracking;
  final DateTime? startedAt;

  RouteTrackingState copyWith({
    LatLng? userPosition,
    List<LatLng>? routePoints,
    List<IntermediatePoint>? intermediatePoints,
    RouteProgress? progress,
    bool? isTracking,
    DateTime? startedAt,
  }) {
    return RouteTrackingState(
      userPosition: userPosition ?? this.userPosition,
      routePoints: routePoints ?? this.routePoints,
      intermediatePoints: intermediatePoints ?? this.intermediatePoints,
      progress: progress ?? this.progress,
      isTracking: isTracking ?? this.isTracking,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

class IntermediatePoint {
  const IntermediatePoint({
    required this.index,
    required this.coordinates,
    required this.label,
    required this.weather,
    required this.distanceFromStart,
    required this.estimatedTimeToReach,
    this.suggestedActivities = const [],
  });

  final int index;
  final LatLng coordinates;
  final String label;
  final WeatherSnapshot weather;
  final double distanceFromStart;
  final Duration estimatedTimeToReach;
  final List<ActivitySuggestion> suggestedActivities;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainChance,
    required this.condition,
    required this.fetchedAt,
    this.temperatureTrend,
  });

  final double temperature;
  final int humidity;
  final double windSpeed;
  final int rainChance;
  final String condition;
  final DateTime fetchedAt;
  final TemperatureTrend? temperatureTrend;
}

class TemperatureTrend {
  const TemperatureTrend({
    required this.next3h,
    required this.direction,
    required this.minNext6h,
  });

  final double next3h;
  final String direction;
  final double minNext6h;
}

class RouteProgress {
  const RouteProgress({
    required this.percentComplete,
    required this.timeElapsed,
    required this.estimatedTimeRemaining,
    required this.distanceTravelledKm,
    required this.totalDistanceKm,
    required this.nextIntermediatePointIndex,
  });

  final double percentComplete;
  final Duration timeElapsed;
  final Duration estimatedTimeRemaining;
  final double distanceTravelledKm;
  final double totalDistanceKm;
  final int nextIntermediatePointIndex;
}

class ActivitySuggestion {
  const ActivitySuggestion({
    required this.id,
    required this.name,
    required this.type,
    required this.suitability,
    required this.reason,
  });

  final String id;
  final String name;
  final String type;
  final double suitability;
  final String reason;

  factory ActivitySuggestion.fromJson(Map<String, dynamic> json) {
    return ActivitySuggestion(
      id: (json['id'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? 'Atividade',
      type: (json['type'] as String?)?.trim() ?? 'outdoor',
      suitability: (json['suitability'] as num?)?.toDouble() ?? 0,
      reason: (json['reason'] as String?)?.trim() ?? '',
    );
  }
}
