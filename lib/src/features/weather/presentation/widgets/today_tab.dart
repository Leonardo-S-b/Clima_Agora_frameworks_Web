import 'package:flutter/material.dart';

import '../../domain/city.dart';
import '../../domain/weather_forecast.dart';
import '../weather_ui_mapper.dart';
import 'pill.dart';
import 'detail_tile.dart';

class TodayTab extends StatelessWidget {
  final City? selectedCity;
  final bool loading;
  final WeatherForecast? forecast;

  const TodayTab({
    super.key,
    required this.selectedCity,
    required this.loading,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedCity == null || forecast == null) {
      return const Center(
        child: Text(
          'Digite uma cidade para buscar',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final current = forecast!.current;
    final kind = mapWeatherCodeToKind(current.weatherCode);
    final label = weatherLabelForCode(current.weatherCode);

    final today = forecast!.daily.isNotEmpty ? forecast!.daily.first : null;
    final tempMax = today?.tempMaxC;
    final tempMin = today?.tempMinC;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperatureC.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (tempMax != null && tempMin != null)
                          Pill(
                            text:
                                '${tempMax.toStringAsFixed(0)}°/${tempMin.toStringAsFixed(0)}°',
                          ),
                        if (current.apparentTemperatureC != null)
                          Pill(
                            text:
                                'Sensação ${current.apparentTemperatureC!.toStringAsFixed(0)}°',
                          ),
                        if (current.windSpeedKmh != null)
                          Pill(
                            text:
                                'Vento ${current.windSpeedKmh!.toStringAsFixed(0)} km/h',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                iconForKind(kind),
                color: Colors.white.withValues(alpha: 0.95),
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Detalhes',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              DetailTile(
                title: 'Precipitação',
                value: current.precipitationMm == null
                    ? '—'
                    : '${current.precipitationMm!.toStringAsFixed(1)} mm',
              ),
              DetailTile(
                title: 'Umidade',
                value: current.relativeHumidity == null
                    ? '—'
                    : '${current.relativeHumidity}%',
              ),
              DetailTile(
                title: 'UV',
                value: current.uvIndex == null
                    ? '—'
                    : current.uvIndex!.toStringAsFixed(0),
              ),
              DetailTile(
                title: 'Visibilidade',
                value: current.visibilityKm == null
                    ? '—'
                    : '${current.visibilityKm!.toStringAsFixed(0)} km',
              ),
              DetailTile(
                title: 'Pressão',
                value: current.pressureHpa == null
                    ? '—'
                    : '${current.pressureHpa!.toStringAsFixed(0)} hPa',
              ),
              DetailTile(
                title: 'Dia/Noite',
                value: current.isDay ? 'Dia' : 'Noite',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
