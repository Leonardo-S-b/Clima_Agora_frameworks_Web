import 'city.dart';

class WeatherUserPreferences {
  final String? userName;
  final City? lastCity;

  const WeatherUserPreferences({
    required this.userName,
    required this.lastCity,
  });

  bool get hasName => userName != null && userName!.trim().isNotEmpty;
}
