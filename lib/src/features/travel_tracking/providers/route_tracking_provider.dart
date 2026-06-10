import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_tracking.dart';

final routeTrackingProvider =
    StateNotifierProvider<RouteTrackingNotifier, RouteTrackingState?>(
  (ref) => RouteTrackingNotifier(),
);

class RouteTrackingNotifier extends StateNotifier<RouteTrackingState?> {
  RouteTrackingNotifier() : super(null);

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

  void startTracking() {
    if (state == null) return;
    state = state!.copyWith(
      isTracking: true,
      startedAt: state!.startedAt ?? DateTime.now(),
    );
  }

  void stopTracking() {
    if (state == null) return;
    state = state!.copyWith(isTracking: false);
  }

  void updateUserPosition(LatLng position) {
    if (state == null) return;
    state = state!.copyWith(userPosition: position);
  }

  void reset() {
    state = null;
  }
}
