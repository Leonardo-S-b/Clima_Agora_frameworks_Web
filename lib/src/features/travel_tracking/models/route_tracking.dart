import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'route_tracking.freezed.dart';

@freezed
class RouteTrackingState with _$RouteTrackingState {
  const factory RouteTrackingState({
    required LatLng userPosition,
    required List<LatLng> routePoints,
    required List<IntermediatePoint> intermediatePoints,
    required RouteProgress progress,
    required bool isTracking,
    required DateTime? startedAt,
  }) = _RouteTrackingState;
}

@freezed
class IntermediatePoint with _$IntermediatePoint {
  const factory IntermediatePoint({
    required int index,
    required LatLng coordinates,
    required String label,
    required WeatherSnapshot weather,
    required double distanceFromStart,
    required Duration estimatedTimeToReach,
  }) = _IntermediatePoint;
}

@freezed
class WeatherSnapshot with _$WeatherSnapshot {
  const factory WeatherSnapshot({
    required double temperature,
    required int humidity,
    required double windSpeed,
    required int rainChance,
    required String condition,
    required DateTime fetchedAt,
  }) = _WeatherSnapshot;
}

@freezed
class RouteProgress with _$RouteProgress {
  const factory RouteProgress({
    required double percentComplete,
    required Duration timeElapsed,
    required Duration estimatedTimeRemaining,
    required double distanceTravelledKm,
    required double totalDistanceKm,
    required int nextIntermediatePointIndex,
  }) = _RouteProgress;
}
