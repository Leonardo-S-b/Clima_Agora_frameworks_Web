

import 'package:clima_agora/src/features/weather/domain/city.dart';
import 'package:clima_agora/src/features/weather/domain/weather_forecast.dart';
import 'package:clima_agora/src/features/weather/presentation/weather_ui_mapper.dart';
import 'package:flutter/material.dart';
import 'toggle_chip.dart';
import 'glass_card.dart';

class ForecastTab extends StatelessWidget {
  final City? selectedCity;
  final bool loading;
  final WeatherForecast? forecast;

  const ForecastTab({super.key, 
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
          'Selecione uma cidade para ver a previsão',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final days = forecast!.daily;
    if (days.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados de previsão diária',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ToggleChip(selected: true, text: 'DIÁRIO'),
              const SizedBox(width: 10),
              ToggleChip(selected: false, text: 'POR HORA'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final day = days[index];
                final kind = mapWeatherCodeToKind(day.weatherCode);
                final dow = weekdayShortPt(day.date);
                return SizedBox(
                  width: 112,
                  child: GlassCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dow.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Icon(
                          iconForKind(kind),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${day.tempMaxC.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${day.tempMinC.toStringAsFixed(0)}°',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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