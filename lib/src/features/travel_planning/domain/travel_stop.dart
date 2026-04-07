import '../../weather/domain/city.dart';
import '../../weather/domain/current_weather.dart';
import 'travel_leg.dart';

class TravelStop {
  final City city;
  final CurrentWeather weather;
  final TravelLeg fromPrevious;

  const TravelStop({
    required this.city,
    required this.weather,
    required this.fromPrevious,
  });
}
