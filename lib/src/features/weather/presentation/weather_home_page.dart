import 'dart:async';

import 'package:flutter/material.dart';
import 'package:clima_agora/src/features/travel_planning/presentation/travel_planning_tab.dart';

import '../data/weather_local_cache.dart';
import '../data/weather_repository.dart';
import '../domain/city.dart';
import '../domain/weather_forecast.dart';
import 'weather_ui_mapper.dart';
import 'widgets/glass_card.dart';
import 'widgets/forecast_tab.dart';
import 'widgets/time_greeting_bubble.dart';
import 'widgets/today_tab.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final _controller = TextEditingController();
  final _nameController = TextEditingController();
  Timer? _debounce;
  Timer? _bubbleTimer;

  final WeatherRepository _repo = WeatherRepository.create();
  final WeatherLocalCache _localCache = WeatherLocalCache();

  List<City> _suggestions = [];
  City? _selectedCity;
  WeatherForecast? _forecast;
  String? _userName;

  bool _loadingCities = false;
  bool _loadingForecast = false;
  bool _loadingPreferences = true;
  bool _didAskUserName = false;
  bool _showGreetingBubble = false;
  String? _error;

  String _backgroundAsset = 'lib/assets/bg_cloudy.jpg';

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _bubbleTimer?.cancel();
    _controller.dispose();
    _nameController.dispose();
    _repo.dispose();
    super.dispose();
  }

  Future<void> _restorePreferences() async {
    final results = await Future.wait<dynamic>([
      _localCache.readPreferences(),
      _localCache.incrementAndGetAppOpenCount(),
    ]);

    final prefs = results[0] as dynamic;
    final appOpenCount = results[1] as int;
    if (!mounted) return;

    setState(() {
      _userName = prefs.userName;
      _loadingPreferences = false;
    });

    final cachedCity = prefs.lastCity;
    if (cachedCity != null) {
      await _selectCity(cachedCity, persistSelection: false);
    }

    if (appOpenCount >= 2 && cachedCity != null) {
      _showTimedGreetingBubble();
    }

    if (!prefs.hasName) {
      _promptForUserName();
    }
  }

  void _showTimedGreetingBubble() {
    _bubbleTimer?.cancel();
    if (!mounted) return;

    setState(() {
      _showGreetingBubble = true;
    });

    _bubbleTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      setState(() {
        _showGreetingBubble = false;
      });
    });
  }

  void _promptForUserName() {
    if (_didAskUserName || !mounted) return;
    _didAskUserName = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showUserNameDialog();
    });
  }

  Future<void> _showUserNameDialog() async {
    _nameController.text = _userName ?? '';

    final savedName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qual seu nome?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_greetingMessage()}! Vamos personalizar sua previsão.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ex.: Maria',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.12),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      final value = _nameController.text.trim();
                      if (value.isNotEmpty) {
                        Navigator.of(context).pop(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        final value = _nameController.text.trim();
                        if (value.isNotEmpty) {
                          Navigator.of(context).pop(value);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: const Color(0xFF15202B),
                      ),
                      child: const Text('Continuar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (savedName == null || savedName.trim().isEmpty) {
      _didAskUserName = false;
      _promptForUserName();
      return;
    }

    await _saveUserName(savedName);
  }

  Future<void> _saveUserName(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return;

    await _localCache.saveUserName(normalized);
    if (!mounted) return;

    setState(() {
      _userName = normalized;
    });
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

  Future<void> _selectCity(City city, {bool persistSelection = true}) async {
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

      if (persistSelection) {
        await _localCache.saveLastCity(city);
      }
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
      length: 3,
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
              const Tab(text: 'Planeje Sua Viagem'),
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
                  if (_loadingPreferences)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _showGreetingBubble
                          ? TimeGreetingBubble(
                              key: const ValueKey('greeting-visible'),
                              message: _buildBubbleMessage(),
                              visible: true,
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('greeting-hidden'),
                            ),
                    ),
                  ),
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
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
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
                          const TravelPlanningTab(),
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

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    return (hour >= 18 || hour < 6) ? 'Boa noite' : 'Bom dia';
  }

  String _buildGreetingTitle() {
    return _greetingMessage();
  }

  String _buildBubbleMessage() {
    final greeting = _buildGreetingTitle();
    final name = _userName?.trim();
    final cityLabel = _selectedCity?.label;

    if (cityLabel == null || cityLabel.isEmpty) {
      return name == null || name.isEmpty ? '$greeting!' : '$greeting, $name!';
    }

    if (name == null || name.isEmpty) {
      return '$greeting! Essa foi sua ultima cidade pesquisada: $cityLabel.';
    }

    return '$greeting, $name! Essa foi sua ultima cidade pesquisada: $cityLabel.';
  }
}
