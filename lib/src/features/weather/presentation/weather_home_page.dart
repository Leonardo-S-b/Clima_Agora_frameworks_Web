import 'dart:async';

import 'package:flutter/material.dart';

import '../data/weather_repository.dart';
import '../domain/city.dart';
import '../domain/weather_forecast.dart';
import 'weather_ui_mapper.dart';
import 'widgets/glass_card.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final _controller = TextEditingController();
  Timer? _debounce;

  final WeatherRepository _repo = WeatherRepository.create();

  List<City> _suggestions = [];
  City? _selectedCity;
  WeatherForecast? _forecast;

  bool _loadingCities = false;
  bool _loadingForecast = false;
  String? _error;

  String _backgroundAsset = 'lib/assets/bg_cloudy.jpg';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _repo.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    if (mounted) {
      setState(() {});
    }

    final query = value.trim();
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (query.isEmpty) {
        if (!mounted) return;
        setState(() {
          _suggestions = [];
          _error = null;
          _loadingCities = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loadingCities = true;
        _error = null;
      });

      try {
        final results = await _repo.searchCities(query);
        if (!mounted) return;
        setState(() {
          _suggestions = results;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = 'Erro ao buscar cidades';
        });
      } finally {
        if (mounted) {
          setState(() {
            _loadingCities = false;
          });
        }
      }
    });
  }

  Future<void> _selectCity(City city) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedCity = city;
      _suggestions = [];
      _loadingForecast = true;
      _error = null;
    });

    try {
      final forecast = await _repo.getForecastForCity(city);

      final kind = mapWeatherCodeToKind(forecast.current.weatherCode);
      final asset = backgroundAssetForKind(kind);

      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _backgroundAsset = asset;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Falha ao carregar previsão';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingForecast = false;
        });
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    setState(() {
      _suggestions = [];
      _error = null;
      _loadingCities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _selectedCity?.label ?? 'Clima Agora';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
                const Tab(text: 'Hoje'),
                const Tab(text: 'Previsão'),
            ],
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _backgroundAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint(
                  'Falha ao carregar plano de fundo: $_backgroundAsset | $error',
                );
                return const SizedBox.shrink();
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xB3000000),
                    Color(0x33000000),
                    Color(0x99000000),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        onChanged: _onQueryChanged,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar cidade',
                          hintStyle:
                              TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          suffixIcon: _controller.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: _clearSearch,
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (_loadingCities)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  if (_suggestions.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GlassCard(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final city = _suggestions[index];
                              return ListTile(
                                title: Text(
                                  city.label,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () => _selectCity(city),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: TabBarView(
                        children: [
                          _TodayTab(
                            selectedCity: _selectedCity,
                            loading: _loadingForecast,
                            forecast: _forecast,
                          ),
                          _ForecastTab(
                            selectedCity: _selectedCity,
                            loading: _loadingForecast,
                            forecast: _forecast,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  final City? selectedCity;
  final bool loading;
  final WeatherForecast? forecast;

  const _TodayTab({
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
                          _Pill(text: '${tempMax.toStringAsFixed(0)}°/${tempMin.toStringAsFixed(0)}°'),
                        if (current.apparentTemperatureC != null)
                          _Pill(
                            text:
                                'Sensação ${current.apparentTemperatureC!.toStringAsFixed(0)}°',
                          ),
                        if (current.windSpeedKmh != null)
                          _Pill(
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
              _DetailTile(
                title: 'Precipitação',
                value: current.precipitationMm == null
                    ? '—'
                    : '${current.precipitationMm!.toStringAsFixed(1)} mm',
              ),
              _DetailTile(
                title: 'Umidade',
                value: current.relativeHumidity == null
                    ? '—'
                    : '${current.relativeHumidity}%',
              ),
              _DetailTile(
                title: 'UV',
                value: current.uvIndex == null
                    ? '—'
                    : current.uvIndex!.toStringAsFixed(0),
              ),
              _DetailTile(
                title: 'Visibilidade',
                value: current.visibilityKm == null
                    ? '—'
                    : '${current.visibilityKm!.toStringAsFixed(0)} km',
              ),
              _DetailTile(
                title: 'Pressão',
                value: current.pressureHpa == null
                    ? '—'
                    : '${current.pressureHpa!.toStringAsFixed(0)} hPa',
              ),
              _DetailTile(
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

class _ForecastTab extends StatelessWidget {
  final City? selectedCity;
  final bool loading;
  final WeatherForecast? forecast;

  const _ForecastTab({
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
              _ToggleChip(selected: true, text: 'DIÁRIO'),
              const SizedBox(width: 10),
              _ToggleChip(selected: false, text: 'POR HORA'),
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
                final dow = _weekdayShortPt(day.date);
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

class _DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const _DetailTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blurSigma: 10,
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final bool selected;
  final String text;

  const _ToggleChip({required this.selected, required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0.28 : 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 0.95 : 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _weekdayShortPt(DateTime date) {
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
