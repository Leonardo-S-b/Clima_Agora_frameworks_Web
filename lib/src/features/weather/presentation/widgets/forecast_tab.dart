import 'package:flutter/material.dart';

import '../../domain/city.dart';
import '../../domain/weather_forecast.dart';
import 'daily_forecast_list.dart';
import 'hourly_forecast_list.dart';
import 'toggle_chip.dart';

enum ForecastViewMode { daily, hourly }

class ForecastTab extends StatefulWidget {
  final City? selectedCity;
  final bool loading;
  final WeatherForecast? forecast;

  const ForecastTab({
    super.key,
    required this.selectedCity,
    required this.loading,
    required this.forecast,
  });

  @override
  State<ForecastTab> createState() => _ForecastTabState();
}

class _ForecastTabState extends State<ForecastTab> {
  ForecastViewMode _mode = ForecastViewMode.daily;

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.selectedCity == null || widget.forecast == null) {
      return const Center(
        child: Text(
          'Selecione uma cidade para ver a previsão',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previsão',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.96),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.selectedCity!.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ToggleChip(
                selected: _mode == ForecastViewMode.daily,
                text: 'DIÁRIO',
                onTap: () {
                  setState(() {
                    _mode = ForecastViewMode.daily;
                  });
                },
              ),
              const SizedBox(width: 10),
              ToggleChip(
                selected: _mode == ForecastViewMode.hourly,
                text: 'POR HORA',
                onTap: () {
                  setState(() {
                    _mode = ForecastViewMode.hourly;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _mode == ForecastViewMode.daily
                ? DailyForecastList(
                    key: const ValueKey('daily'),
                    days: widget.forecast!.daily,
                  )
                : HourlyForecastList(
                    key: const ValueKey('hourly'),
                    hours: widget.forecast!.hourly,
                    anchorTime: widget.forecast!.current.time,
                  ),
          ),
        ],
      ),
    );
  }
}
