import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/current_weather.dart';
import '../domain/weather_forecast.dart';

class OpenMeteoForecastApi {
  final http.Client _client;

  OpenMeteoForecastApi(this._client);

  Future<WeatherForecast> getForecast({
    required double latitude,
    required double longitude,
    String? timezone,
    int forecastDays = 7,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,weather_code,is_day,wind_speed_10m,pressure_msl,visibility,uv_index',
      'hourly':
          'temperature_2m,apparent_temperature,weather_code,precipitation_probability,wind_speed_10m',
      'daily': 'temperature_2m_max,temperature_2m_min,weather_code',
      'forecast_days': forecastDays.toString(),
      'timezone': timezone ?? 'auto',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Previsão falhou: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    final currentJson = body['current'] as Map<String, dynamic>;
    final current = CurrentWeather.fromJson(currentJson);

    final hourlyJson = body['hourly'] as Map<String, dynamic>?;
    final hours = <ForecastHour>[];
    if (hourlyJson != null) {
      final times =
          (hourlyJson['time'] as List?)?.cast<String>() ?? const <String>[];
      final codes =
          (hourlyJson['weather_code'] as List?)?.cast<num>() ?? const <num>[];
      final temps =
          (hourlyJson['temperature_2m'] as List?)?.cast<num>() ?? const <num>[];
      final feelsLike =
          (hourlyJson['apparent_temperature'] as List?)?.cast<num>() ??
          const <num>[];
      final rainChance =
          (hourlyJson['precipitation_probability'] as List?)?.cast<num>() ??
          const <num>[];
      final wind =
          (hourlyJson['wind_speed_10m'] as List?)?.cast<num>() ?? const <num>[];

      final count = <int>[
        times.length,
        codes.length,
        temps.length,
        feelsLike.length,
        rainChance.length,
        wind.length,
      ].reduce((a, b) => a < b ? a : b);

      for (var i = 0; i < count; i++) {
        hours.add(
          ForecastHour(
            time: DateTime.parse(times[i]),
            weatherCode: codes[i].toInt(),
            temperatureC: temps[i].toDouble(),
            apparentTemperatureC: feelsLike[i].toDouble(),
            precipitationProbability: rainChance[i].toInt(),
            windSpeedKmh: wind[i].toDouble(),
          ),
        );
      }
    }

    final dailyJson = body['daily'] as Map<String, dynamic>?;
    final days = <ForecastDay>[];
    if (dailyJson != null) {
      final times =
          (dailyJson['time'] as List?)?.cast<String>() ?? const <String>[];
      final codes =
          (dailyJson['weather_code'] as List?)?.cast<num>() ?? const <num>[];
      final maxs =
          (dailyJson['temperature_2m_max'] as List?)?.cast<num>() ??
          const <num>[];
      final mins =
          (dailyJson['temperature_2m_min'] as List?)?.cast<num>() ??
          const <num>[];

      final count = <int>[
        times.length,
        codes.length,
        maxs.length,
        mins.length,
      ].reduce((a, b) => a < b ? a : b);
      for (var i = 0; i < count; i++) {
        days.add(
          ForecastDay(
            date: DateTime.parse(times[i]),
            weatherCode: codes[i].toInt(),
            tempMaxC: maxs[i].toDouble(),
            tempMinC: mins[i].toDouble(),
          ),
        );
      }
    }

    return WeatherForecast(current: current, daily: days, hourly: hours);
  }

  Future<CurrentWeather> getCurrentWeather({
    required double latitude,
    required double longitude,
    String? timezone,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,weather_code,is_day,wind_speed_10m,pressure_msl,visibility,uv_index',
      'timezone': timezone ?? 'auto',
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Previsão falhou: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    return CurrentWeather.fromJson(current);
  }
}
