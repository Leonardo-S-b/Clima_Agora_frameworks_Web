import 'package:flutter/material.dart';

enum WeatherKind { sunny, cloudy, rain, snow }

WeatherKind mapWeatherCodeToKind(int code) {
  if (code == 0) return WeatherKind.sunny;

  if (code >= 1 && code <= 3) return WeatherKind.cloudy;

  if (code == 45 || code == 48) return WeatherKind.cloudy;

  if ((code >= 51 && code <= 67) ||
      (code >= 80 && code <= 82) ||
      (code >= 95 && code <= 99)) {
    return WeatherKind.rain;
  }

  if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
    return WeatherKind.snow;
  }

  return WeatherKind.cloudy;
}

String backgroundAssetForKind(WeatherKind kind) {
  switch (kind) {
    case WeatherKind.sunny:
      return 'lib/assets/bg_sunny.jpg';
    case WeatherKind.cloudy:
      return 'lib/assets/bg_cloudy.jpg';
    case WeatherKind.rain:
      return 'lib/assets/bg_rain.jpg';
    case WeatherKind.snow:
      return 'lib/assets/bg_snow.jpg';
  }
}

String weatherLabelForCode(int code) {
  // Referência: Open-Meteo WMO weather interpretation codes.
  if (code == 0) return 'Céu limpo';
  if (code >= 1 && code <= 3) return 'Parcialmente nublado';
  if (code == 45 || code == 48) return 'Neblina';

  if (code >= 51 && code <= 57) return 'Garoa';
  if (code >= 61 && code <= 67) return 'Chuva';
  if (code >= 71 && code <= 77) return 'Neve';
  if (code >= 80 && code <= 82) return 'Pancadas de chuva';
  if (code >= 85 && code <= 86) return 'Pancadas de neve';
  if (code >= 95 && code <= 99) return 'Trovoadas';

  return 'Nublado';
}

IconData iconForKind(WeatherKind kind) {
  switch (kind) {
    case WeatherKind.sunny:
      return Icons.wb_sunny_outlined;
    case WeatherKind.cloudy:
      return Icons.cloud_outlined;
    case WeatherKind.rain:
      return Icons.umbrella_outlined;
    case WeatherKind.snow:
      return Icons.ac_unit;
  }
}
