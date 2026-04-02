import 'dart:async';

import 'package:flutter/material.dart';

import '../data/weather_repository.dart';
import '../domain/city.dart';
import '../domain/weather_forecast.dart';
import 'weather_ui_mapper.dart';
import 'widgets/glass_card.dart';
import 'widgets/forecast_tab.dart';
import 'widgets/today_tab.dart';


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
                          TodayTab(
                            selectedCity: _selectedCity,
                            loading: _loadingForecast,
                            forecast: _forecast,
                          ),
                          ForecastTab(
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













