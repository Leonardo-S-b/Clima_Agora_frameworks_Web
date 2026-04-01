class CurrentWeather {
  final double temperatureC;
  final double? apparentTemperatureC;
  final int? relativeHumidity;
  final double? windSpeedKmh;
  final double? precipitationMm;
  final double? pressureHpa;
  final double? visibilityKm;
  final double? uvIndex;
  final int weatherCode;
  final bool isDay;

  CurrentWeather({
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.relativeHumidity,
    required this.windSpeedKmh,
    required this.precipitationMm,
    required this.pressureHpa,
    required this.visibilityKm,
    required this.uvIndex,
    required this.weatherCode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperatureC: (json['temperature_2m'] as num).toDouble(),
      apparentTemperatureC: (json['apparent_temperature'] as num?)?.toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt(),
      windSpeedKmh: (json['wind_speed_10m'] as num?)?.toDouble(),
      precipitationMm: (json['precipitation'] as num?)?.toDouble(),
      pressureHpa: (json['pressure_msl'] as num?)?.toDouble(),
      visibilityKm: (json['visibility'] as num?) == null
          ? null
          : ((json['visibility'] as num).toDouble() / 1000.0),
      uvIndex: (json['uv_index'] as num?)?.toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      isDay: ((json['is_day'] as num).toInt()) == 1,
    );
  }
}
