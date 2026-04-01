import 'package:http/http.dart' as http;

import '../domain/city.dart';
import '../domain/current_weather.dart';
import '../domain/weather_forecast.dart';
import 'open_meteo_forecast_api.dart';
import 'open_meteo_geocoding_api.dart';

class WeatherRepository {
  final http.Client _client;
  final OpenMeteoGeocodingApi _geocoding;
  final OpenMeteoForecastApi _forecast;

  WeatherRepository._(this._client, this._geocoding, this._forecast);

  factory WeatherRepository.create() {
    final client = http.Client();
    return WeatherRepository._(
      client,
      OpenMeteoGeocodingApi(client),
      OpenMeteoForecastApi(client),
    );
  }

  Future<List<City>> searchCities(String query) => _geocoding.searchCities(query);

  Future<CurrentWeather> getCurrentWeatherForCity(City city) {
    return _forecast.getCurrentWeather(
      latitude: city.latitude,
      longitude: city.longitude,
      timezone: city.timezone,
    );
  }

  Future<WeatherForecast> getForecastForCity(City city, {int forecastDays = 7}) {
    return _forecast.getForecast(
      latitude: city.latitude,
      longitude: city.longitude,
      timezone: city.timezone,
      forecastDays: forecastDays,
    );
  }

  void dispose() {
    _client.close();
  }
}
