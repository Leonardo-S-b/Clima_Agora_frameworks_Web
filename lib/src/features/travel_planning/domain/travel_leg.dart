import '../../weather/domain/current_weather.dart';

class TravelLeg {
  final double distanceKm;
  final Duration duration;
  final CurrentWeather? routeWeather;

  const TravelLeg({
    required this.distanceKm,
    required this.duration,
    required this.routeWeather,
  });
}
