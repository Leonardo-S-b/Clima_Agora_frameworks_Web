import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_tracking.dart';
import '../services/location_service.dart';

final routeTrackingProvider =
    StateNotifierProvider<RouteTrackingNotifier, RouteTrackingState?>(
  (ref) => RouteTrackingNotifier(),
);

class RouteTrackingNotifier extends StateNotifier<RouteTrackingState?> {
  RouteTrackingNotifier() : super(null);

  final _locationService = LocationService();
  final _distance = const Distance();
  StreamSubscription<Position>? _positionSubscription;

  void loadSession({
    required LatLng startPosition,
    required List<LatLng> routePoints,
    required List<IntermediatePoint> intermediatePoints,
    required double totalDistanceKm,
    required int estimatedDurationSeconds,
  }) {
    state = RouteTrackingState(
      userPosition: startPosition,
      routePoints: routePoints,
      intermediatePoints: intermediatePoints,
      progress: RouteProgress(
        percentComplete: 0,
        timeElapsed: Duration.zero,
        estimatedTimeRemaining: Duration(seconds: estimatedDurationSeconds),
        distanceTravelledKm: 0,
        totalDistanceKm: totalDistanceKm,
        nextIntermediatePointIndex: 0,
      ),
      isTracking: false,
      startedAt: null,
    );
  }

  Future<void> startTracking() async {
    if (state == null) return;
    await _locationService.requestPermissions();
    await _positionSubscription?.cancel();

    state = state!.copyWith(
      isTracking: true,
      startedAt: state!.startedAt ?? DateTime.now(),
    );

    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        updateUserPosition(LatLng(position.latitude, position.longitude));
      },
    );
  }

  Future<void> stopTracking() async {
    if (state == null) return;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state!.copyWith(isTracking: false);
  }

  void updateUserPosition(LatLng position) {
    if (state == null) return;
    state = state!.copyWith(
      userPosition: position,
      progress: _calculateProgress(position, state!),
    );
  }

  void reset() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = null;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  RouteProgress _calculateProgress(
    LatLng userPosition,
    RouteTrackingState current,
  ) {
    if (current.routePoints.length < 2 || current.progress.totalDistanceKm <= 0) {
      return current.progress;
    }

    final segmentDistancesKm = <double>[];
    var totalRouteKm = 0.0;
    for (var i = 1; i < current.routePoints.length; i++) {
      final segmentKm =
          _distance(current.routePoints[i - 1], current.routePoints[i]) / 1000;
      segmentDistancesKm.add(segmentKm);
      totalRouteKm += segmentKm;
    }

    var nearestIndex = 0;
    var nearestDistanceMeters = double.infinity;
    for (var i = 0; i < current.routePoints.length; i++) {
      final distanceMeters = _distance(userPosition, current.routePoints[i]);
      if (distanceMeters < nearestDistanceMeters) {
        nearestDistanceMeters = distanceMeters;
        nearestIndex = i;
      }
    }

    final travelledKm = segmentDistancesKm
        .take(nearestIndex)
        .fold<double>(0, (sum, distanceKm) => sum + distanceKm);
    final percentComplete = totalRouteKm == 0
        ? 0.0
        : (travelledKm / totalRouteKm * 100).clamp(0.0, 100.0);

    final startedAt = current.startedAt;
    final elapsed = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);
    final remainingRatio = (1 - (percentComplete / 100)).clamp(0.0, 1.0);
    final remainingSeconds =
        (current.progress.estimatedTimeRemaining.inSeconds * remainingRatio)
            .round();

    return RouteProgress(
      percentComplete: percentComplete,
      timeElapsed: elapsed,
      estimatedTimeRemaining: Duration(seconds: remainingSeconds),
      distanceTravelledKm: travelledKm,
      totalDistanceKm: current.progress.totalDistanceKm,
      nextIntermediatePointIndex: nearestIndex.clamp(
        0,
        current.intermediatePoints.length,
      ),
    );
  }
}
