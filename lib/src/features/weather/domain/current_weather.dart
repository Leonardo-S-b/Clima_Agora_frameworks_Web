class CurrentWeather {
  final double temperatureC;
  final int weatherCode;
  final bool isDay;

  CurrentWeather({
    required this.temperatureC,
    required this.weatherCode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperatureC: (json['temperature_2m'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      isDay: ((json['is_day'] as num).toInt()) == 1,
    );
  }
}
