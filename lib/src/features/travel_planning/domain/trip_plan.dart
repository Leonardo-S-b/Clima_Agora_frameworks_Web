import 'travel_stop.dart';

class TripPlan {
  final List<TravelStop> stops;
  final double totalDistanceKm;
  final Duration totalDuration;

  const TripPlan({
    required this.stops,
    required this.totalDistanceKm,
    required this.totalDuration,
  });
}
