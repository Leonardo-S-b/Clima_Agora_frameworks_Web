import 'current_weather.dart';

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

  WeatherForecast({
    required this.current,
    required this.daily,
  });
}
