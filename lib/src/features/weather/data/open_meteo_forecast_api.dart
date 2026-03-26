import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/current_weather.dart';

class OpenMeteoForecastApi {
  final http.Client _client;

  OpenMeteoForecastApi(this._client);

  Future<CurrentWeather> getCurrentWeather({
    required double latitude,
    required double longitude,
    String? timezone,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': 'temperature_2m,weather_code,is_day',
        'timezone': timezone ?? 'auto',
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Forecast falhou: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    return CurrentWeather.fromJson(current);
  }
}
