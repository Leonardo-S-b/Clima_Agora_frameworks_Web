import 'package:flutter/material.dart';

import '../../domain/weather_forecast.dart';
import '../weather_ui_mapper.dart';
import 'glass_card.dart';

class DailyForecastList extends StatelessWidget {
  final List<ForecastDay> days;

  const DailyForecastList({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de previsão diária',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SizedBox(
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final day = days[index];
          final kind = mapWeatherCodeToKind(day.weatherCode);
          final dow = weekdayShortPt(day.date);

          return SizedBox(
            width: 122,
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dow.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(iconForKind(kind), color: Colors.white, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      '${day.tempMaxC.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.tempMinC.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: Center(
                        child: Text(
                          weatherLabelForCode(day.weatherCode),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 9.5,
                            height: 1.05,
                          ),
                        ),
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

String weekdayShortPt(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return 'Seg';
    case DateTime.tuesday:
      return 'Ter';
    case DateTime.wednesday:
      return 'Qua';
    case DateTime.thursday:
      return 'Qui';
    case DateTime.friday:
      return 'Sex';
    case DateTime.saturday:
      return 'Sáb';
    case DateTime.sunday:
      return 'Dom';
  }
  return '';
}
