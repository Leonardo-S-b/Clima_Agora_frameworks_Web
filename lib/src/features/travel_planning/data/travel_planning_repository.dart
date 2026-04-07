import 'package:http/http.dart' as http;

import '../../weather/data/weather_repository.dart';
import '../../weather/domain/city.dart';
import '../../weather/domain/current_weather.dart';
import '../domain/travel_leg.dart';
import '../domain/travel_stop.dart';
import '../domain/trip_plan.dart';
import 'open_route_service_api.dart';

class TravelPlanningRepository {
  final WeatherRepository _weatherRepository;
  final OpenRouteServiceApi _routeApi;

  TravelPlanningRepository._(this._weatherRepository, this._routeApi);

  factory TravelPlanningRepository.create() {
    final weatherRepository = WeatherRepository.create();
    final client = http.Client();
    final routeApi = OpenRouteServiceApi(client);
    return TravelPlanningRepository._(weatherRepository, routeApi);
  }

  Future<List<City>> searchCities(String query) {
    return _weatherRepository.searchCities(query);
  }

  Future<TripPlan> planTrip({
    required double originLat,
    required double originLon,
    required List<City> stops,
  }) async {
    if (stops.isEmpty) {
      return const TripPlan(
        stops: [],
        totalDistanceKm: 0,
        totalDuration: Duration.zero,
      );
    }

    final routeLegs = await _routeApi.getDrivingLegs(
      originLat: originLat,
      originLon: originLon,
      points: stops
          .map((city) => {'lat': city.latitude, 'lon': city.longitude})
          .toList(growable: false),
    );

    final stopItems = <TravelStop>[];

    var previousLat = originLat;
    var previousLon = originLon;

    for (var index = 0; index < stops.length; index++) {
      final city = stops[index];
      final cityWeather = await _weatherRepository
          .getCurrentWeatherForCoordinates(
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone,
          );

      final leg = index < routeLegs.length
          ? routeLegs[index]
          : const RouteLegResult(distanceKm: 0, duration: Duration.zero);

      final midpointLat = (previousLat + city.latitude) / 2;
      final midpointLon = (previousLon + city.longitude) / 2;

      CurrentWeather? routeWeather;
      try {
        routeWeather = await _weatherRepository.getCurrentWeatherForCoordinates(
          latitude: midpointLat,
          longitude: midpointLon,
          timezone: city.timezone,
        );
      } catch (_) {
        routeWeather = null;
      }

      stopItems.add(
        TravelStop(
          city: city,
          weather: cityWeather,
          fromPrevious: TravelLeg(
            distanceKm: leg.distanceKm,
            duration: leg.duration,
            routeWeather: routeWeather,
          ),
        ),
      );

      previousLat = city.latitude;
      previousLon = city.longitude;
    }

    final totalDistanceKm = stopItems.fold<double>(
      0,
      (sum, item) => sum + item.fromPrevious.distanceKm,
    );
    final totalMinutes = stopItems.fold<int>(
      0,
      (sum, item) => sum + item.fromPrevious.duration.inMinutes,
    );

    return TripPlan(
      stops: stopItems,
      totalDistanceKm: totalDistanceKm,
      totalDuration: Duration(minutes: totalMinutes),
    );
  }

  void dispose() {
    _routeApi.dispose();
    _weatherRepository.dispose();
  }
}
