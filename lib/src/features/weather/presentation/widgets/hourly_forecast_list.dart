import 'package:flutter/material.dart';

import '../../domain/weather_forecast.dart';
import '../weather_ui_mapper.dart';
import 'glass_card.dart';

class HourlyForecastList extends StatelessWidget {
  final List<ForecastHour> hours;
  final DateTime anchorTime;

  const HourlyForecastList({
    super.key,
    required this.hours,
    required this.anchorTime,
  });

  @override
  Widget build(BuildContext context) {
    final visibleHours = hours
        .where((hour) => !hour.time.isBefore(anchorTime))
        .take(24)
        .toList(growable: false);

    if (visibleHours.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de previsão por hora',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleHours.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final hour = visibleHours[index];
          final kind = mapWeatherCodeToKind(hour.weatherCode);

          return SizedBox(
            width: 106,
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatHourLabel(hour.time),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(iconForKind(kind), color: Colors.white, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      '${hour.temperatureC.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weatherLabelForCode(hour.weatherCode),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 10,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (hour.apparentTemperatureC != null)
                      Text(
                        'Sens. ${hour.apparentTemperatureC!.toStringAsFixed(0)}°',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 9.5,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      'Chuva ${hour.precipitationProbability ?? 0}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vento ${hour.windSpeedKmh?.toStringAsFixed(0) ?? '—'} km/h',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatHourLabel(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  return '$hour h'.replaceAll(' ', '');
}
