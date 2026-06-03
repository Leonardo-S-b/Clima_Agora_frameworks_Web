import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_tracking.dart';

final routeTrackingProvider = StateNotifierProvider<RouteTrackingNotifier, RouteTrackingState?>(
  (ref) => RouteTrackingNotifier(),
);

class RouteTrackingNotifier extends StateNotifier<RouteTrackingState?> {
  RouteTrackingNotifier(): super(null);

  void init(LatLng startPosition) {
    state = RouteTrackingState(
      userPosition: startPosition,
      routePoints: [startPosition],
      intermediatePoints: [],
      progress: RouteProgress(
        percentComplete: 0,
        timeElapsed: Duration.zero,
        estimatedTimeRemaining: Duration.zero,
        distanceTravelledKm: 0,
        totalDistanceKm: 0,
        nextIntermediatePointIndex: 0,
      ),
      isTracking: false,
      startedAt: null,
    );
  }

  void startTracking() {
    if (state == null) return;
    state = state!.copyWith(isTracking: true, startedAt: DateTime.now());
  }

  void stopTracking() {
    if (state == null) return;
    state = state!.copyWith(isTracking: false);
  }
}
