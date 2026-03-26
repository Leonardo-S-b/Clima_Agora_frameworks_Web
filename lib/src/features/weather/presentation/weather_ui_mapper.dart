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
