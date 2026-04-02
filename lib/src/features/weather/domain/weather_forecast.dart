import 'current_weather.dart';

class ForecastHour {
  final DateTime time;
  final int weatherCode;
  final double temperatureC;
  final double? apparentTemperatureC;
  final int? precipitationProbability;
  final double? windSpeedKmh;

  ForecastHour({
    required this.time,
    required this.weatherCode,
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.precipitationProbability,
    required this.windSpeedKmh,
  });
}

class ForecastDay {
  final DateTime date;
  final int weatherCode;
  final double tempMaxC;
  final double tempMinC;

  ForecastDay({
    required this.date,
    required this.weatherCode,
    required this.tempMaxC,
    required this.tempMinC,
  });
}

class WeatherForecast {
  final CurrentWeather current;
  final List<ForecastDay> daily;
  final List<ForecastHour> hourly;

  WeatherForecast({
    required this.current,
    required this.daily,
    required this.hourly,
  });
}
