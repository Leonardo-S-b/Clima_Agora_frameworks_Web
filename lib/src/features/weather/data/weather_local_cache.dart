import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/city.dart';
import '../domain/weather_user_preferences.dart';

class WeatherLocalCache {
  static const _userNameKey = 'weather.userName';
  static const _lastCityKey = 'weather.lastCity';
  static const _appOpenCountKey = 'weather.appOpenCount';

  Future<WeatherUserPreferences> readPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final userName = prefs.getString(_userNameKey);
    final lastCityJson = prefs.getString(_lastCityKey);

    City? lastCity;
    if (lastCityJson != null && lastCityJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(lastCityJson) as Map<String, dynamic>;
        lastCity = City.fromJson(decoded);
      } catch (_) {
        lastCity = null;
      }
    }

    return WeatherUserPreferences(userName: userName, lastCity: lastCity);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name.trim());
  }

  Future<void> saveLastCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, jsonEncode(city.toJson()));
  }

  Future<int> incrementAndGetAppOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_appOpenCountKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_appOpenCountKey, next);
    return next;
  }
}
