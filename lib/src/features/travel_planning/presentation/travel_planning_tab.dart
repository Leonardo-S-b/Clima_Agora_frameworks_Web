import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../weather/domain/city.dart';
import '../../weather/domain/current_weather.dart';
import '../../weather/presentation/widgets/glass_card.dart';
import '../../travel_tracking/data/route_tracking_api.dart';
import '../../travel_tracking/models/route_tracking.dart';
import '../../travel_tracking/providers/route_tracking_provider.dart';
import '../../travel_tracking/widgets/route_map_widget.dart';
import '../data/gemini_activity_api.dart';
import '../data/travel_planning_repository.dart';
import '../domain/trip_plan.dart';
import 'widgets/travel_stop_card.dart';

enum OriginMode { currentLocation, manualCity }

class TravelPlanningTab extends ConsumerStatefulWidget {
  const TravelPlanningTab({super.key});

  @override
  ConsumerState<TravelPlanningTab> createState() => _TravelPlanningTabState();
}

class _TravelPlanningTabState extends ConsumerState<TravelPlanningTab> {
  final _repository = TravelPlanningRepository.create();
  final _aiClient = http.Client();
  final _trackingClient = http.Client();
  late final GeminiActivityApi _aiApi;
  late final RouteTrackingApi _trackingApi;
  final _originController = TextEditingController();
  final _stopController = TextEditingController();
  Timer? _originDebounce;
  Timer? _stopDebounce;

  OriginMode _originMode = OriginMode.currentLocation;
  City? _originCity;
  Position? _originPosition;

  List<City> _originSuggestions = [];
  List<City> _stopSuggestions = [];
  final List<City> _selectedStops = [];

  bool _loadingOriginSuggestions = false;
  bool _loadingStopSuggestions = false;
  bool _loadingOrigin = false;
  bool _loadingPlan = false;
  String? _error;
  TripPlan? _tripPlan;
  RouteTrackingPlan? _trackingPlan;
  String? _trackingNotice;

  @override
  void initState() {
    super.initState();
    _aiApi = GeminiActivityApi(_aiClient);
    _trackingApi = RouteTrackingApi(_trackingClient);
  }

  @override
  void dispose() {
    _originDebounce?.cancel();
    _stopDebounce?.cancel();
    _originController.dispose();
    _stopController.dispose();
    _repository.dispose();
    _aiApi.dispose();
    _trackingClient.close();
    super.dispose();
  }

  Future<void> _requestCurrentLocation() async {
    setState(() {
      _loadingOrigin = true;
      _error = null;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() {
          _error =
              'Ative a localização para usar sua posição atual como origem.';
          _loadingOrigin = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final deniedForever = permission == LocationPermission.deniedForever;
        setState(() {
          _error = deniedForever
              ? 'Permissão de localização negada permanentemente. Abra as configurações do app para permitir acesso.'
              : 'Permissão de localização negada. Escolha origem manual ou permita acesso.';
          _loadingOrigin = false;
        });

        if (deniedForever) {
          await Geolocator.openAppSettings();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _originPosition = position;
        _loadingOrigin = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível obter sua localização atual agora.';
        _loadingOrigin = false;
      });
    }
  }

  void _onOriginSearchChanged(String value) {
    final query = value.trim();
    _originDebounce?.cancel();

    _originDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        if (!mounted) return;
        setState(() {
          _originSuggestions = [];
          _loadingOriginSuggestions = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loadingOriginSuggestions = true;
      });

      try {
        final results = await _repository.searchCities(query);
        if (!mounted) return;
        setState(() {
          _originSuggestions = results;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = 'Falha ao buscar cidade de origem.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _loadingOriginSuggestions = false;
          });
        }
      }
    });
  }

  void _onStopSearchChanged(String value) {
    final query = value.trim();
    _stopDebounce?.cancel();

    _stopDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        if (!mounted) return;
        setState(() {
          _stopSuggestions = [];
          _loadingStopSuggestions = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loadingStopSuggestions = true;
      });

      try {
        final results = await _repository.searchCities(query);
        if (!mounted) return;
        setState(() {
          _stopSuggestions = results;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = 'Falha ao buscar cidades da viagem.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _loadingStopSuggestions = false;
          });
        }
      }
    });
  }

  void _selectOriginCity(City city) {
    setState(() {
      _originCity = city;
      _originController.text = city.label;
      _originSuggestions = [];
      _error = null;
      _tripPlan = null;
    });
  }

  void _addStop(City city) {
    final exists = _selectedStops.any((item) => item.label == city.label);
    if (exists) return;

    setState(() {
      _selectedStops.add(city);
      _stopController.clear();
      _stopSuggestions = [];
      _tripPlan = null;
      _error = null;
    });
  }

  void _removeStop(City city) {
    setState(() {
      _selectedStops.removeWhere((item) => item.label == city.label);
      _tripPlan = null;
    });
  }

  void _changeOriginMode(OriginMode mode) {
    setState(() {
      _originMode = mode;
      _error = null;
      _tripPlan = null;
      _originSuggestions = [];

      if (mode == OriginMode.currentLocation) {
        _originCity = null;
        _originController.clear();
      } else {
        _originPosition = null;
      }
    });

    if (mode == OriginMode.currentLocation && _originPosition == null) {
      _requestCurrentLocation();
    }
  }

  Future<void> _planTrip() async {
    if (_selectedStops.isEmpty) {
      setState(() {
        _error = 'Adicione pelo menos uma cidade de destino.';
      });
      return;
    }

    final originCoords = _resolveOriginCoordinates();
    if (originCoords == null) {
      setState(() {
        _error = _originMode == OriginMode.currentLocation
            ? 'Permita a localização para usar sua posição atual.'
            : 'Escolha a cidade de origem manual para continuar.';
      });
      return;
    }

    setState(() {
      _loadingPlan = true;
      _error = null;
    });

    try {
      final plan = await _repository.planTrip(
        originLat: originCoords.$1,
        originLon: originCoords.$2,
        stops: _selectedStops,
      );

      if (!mounted) return;
      setState(() {
        _tripPlan = plan;
        _trackingPlan = null;
        _trackingNotice = null;
      });
      await _loadTrackingSession(plan, originCoords);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível planejar a viagem agora.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingPlan = false;
        });
      }
    }
  }

  (double, double)? _resolveOriginCoordinates() {
    if (_originMode == OriginMode.currentLocation) {
      if (_originPosition == null) return null;
      return (_originPosition!.latitude, _originPosition!.longitude);
    }

    if (_originCity == null) return null;
    return (_originCity!.latitude, _originCity!.longitude);
  }

  Future<void> _loadTrackingSession(
    TripPlan plan,
    (double, double) originCoords,
  ) async {
    final origin = LatLng(originCoords.$1, originCoords.$2);
    final stops = plan.stops
        .map((stop) => LatLng(stop.city.latitude, stop.city.longitude))
        .toList(growable: false);

    try {
      final trackingPlan = await _trackingApi.planRoute(
        origin: origin,
        stops: stops,
      );

      ref
          .read(routeTrackingProvider.notifier)
          .loadSession(
            startPosition: origin,
            routePoints: trackingPlan.routePoints,
            intermediatePoints: _mergeTrackingWeatherPoints(plan, trackingPlan),
            totalDistanceKm: trackingPlan.totalDistanceKm,
            estimatedDurationSeconds: trackingPlan.estimatedDuration.inSeconds,
          );

      if (!mounted) return;
      setState(() {
        _trackingPlan = trackingPlan;
        _trackingNotice =
            'Rota real carregada com clima atual no local, no caminho e no destino.';
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _trackingNotice =
            'Backend de rota real indisponivel. Mostrando rota aproximada entre as cidades.';
      });
    }

    final routePoints = <LatLng>[origin, ...stops];

    final intermediatePoints = plan.stops
        .asMap()
        .entries
        .map((entry) {
          final stop = entry.value;
          final weather = stop.fromPrevious.routeWeather ?? stop.weather;

          return IntermediatePoint(
            index: entry.key,
            coordinates: LatLng(stop.city.latitude, stop.city.longitude),
            label: stop.city.name,
            weather: _toWeatherSnapshot(weather),
            distanceFromStart: plan.stops
                .take(entry.key + 1)
                .fold<double>(
                  0,
                  (sum, item) => sum + item.fromPrevious.distanceKm,
                ),
            estimatedTimeToReach: Duration(
              minutes: plan.stops
                  .take(entry.key + 1)
                  .fold<int>(
                    0,
                    (sum, item) => sum + item.fromPrevious.duration.inMinutes,
                  ),
            ),
          );
        })
        .toList(growable: false);

    ref
        .read(routeTrackingProvider.notifier)
        .loadSession(
          startPosition: origin,
          routePoints: routePoints,
          intermediatePoints: intermediatePoints,
          totalDistanceKm: plan.totalDistanceKm,
          estimatedDurationSeconds: plan.totalDuration.inSeconds,
        );
  }

  List<IntermediatePoint> _mergeTrackingWeatherPoints(
    TripPlan plan,
    RouteTrackingPlan trackingPlan,
  ) {
    final points = <IntermediatePoint>[...trackingPlan.intermediatePoints];

    for (var index = 0; index < plan.stops.length; index++) {
      final stop = plan.stops[index];
      final isDestination = index == plan.stops.length - 1;

      points.add(
        IntermediatePoint(
          index: 1000 + index,
          coordinates: LatLng(stop.city.latitude, stop.city.longitude),
          label: isDestination ? 'Destino: ${stop.city.name}' : stop.city.name,
          weather: isDestination
              ? trackingPlan.destinationWeather
              : _toWeatherSnapshot(stop.weather),
          distanceFromStart: plan.stops
              .take(index + 1)
              .fold<double>(
                0,
                (sum, item) => sum + item.fromPrevious.distanceKm,
              ),
          estimatedTimeToReach: Duration(
            minutes: plan.stops
                .take(index + 1)
                .fold<int>(
                  0,
                  (sum, item) => sum + item.fromPrevious.duration.inMinutes,
                ),
          ),
        ),
      );
    }

    return points;
  }

  WeatherSnapshot _toWeatherSnapshot(CurrentWeather weather) {
    final precipitation = weather.precipitationMm ?? 0;

    return WeatherSnapshot(
      temperature: weather.temperatureC,
      humidity: weather.relativeHumidity ?? 0,
      windSpeed: weather.windSpeedKmh ?? 0,
      rainChance: precipitation > 0 ? 80 : 15,
      condition: _conditionFromWeatherCode(weather.weatherCode),
      fetchedAt: weather.time,
    );
  }

  String _conditionFromWeatherCode(int code) {
    if (code == 0) return 'sunny';
    if (code == 1 || code == 2) return 'cloudy';
    if (code == 3 || code == 45 || code == 48) return 'foggy';
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return 'rainy';
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return 'snowy';
    }
    if (code == 95 || code == 96 || code == 99) return 'stormy';
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Planeje Sua Viagem',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha uma ou mais cidades. Vamos calcular rota de carro, clima por cidade e clima no caminho.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 13,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          _buildOriginSelector(),
          const SizedBox(height: 12),
          _buildStopsSelector(),
          const SizedBox(height: 12),
          _buildSelectedRouteOverview(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _loadingPlan || _selectedStops.isEmpty
                      ? null
                      : _planTrip,
                  icon: const Icon(Icons.playlist_add_check),
                  label: Text(_loadingPlan ? 'Planejando...' : 'Gerar roteiro'),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            ),
          if (_tripPlan != null) ...[
            const SizedBox(height: 16),
            _buildTrackingMap(),
            const SizedBox(height: 16),
            _buildStopsHeader(),
            const SizedBox(height: 8),
            ..._tripPlan!.stops.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TravelStopCard(
                  index: entry.key,
                  stop: entry.value,
                  aiApi: _aiApi,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingMap() {
    final trackingPlan = _trackingPlan;

    return GlassCard(
      padding: EdgeInsets.zero,
      blurSigma: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: _mapHeightFor(context),
              child: RouteMapWidget(
                compact: true,
                onExpand: _openFullscreenMap,
                onToggleTracking: _toggleTracking,
              ),
            ),
          ),
          if (trackingPlan != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                children: [
                  _weatherSummaryRow(
                    title: 'Agora',
                    weather: trackingPlan.originWeather,
                  ),
                  const SizedBox(height: 6),
                  _weatherSummaryRow(
                    title: 'Destino',
                    weather: trackingPlan.destinationWeather,
                  ),
                ],
              ),
            )
          else if (_trackingNotice != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(
                _trackingNotice!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _weatherSummaryRow({
    required String title,
    required WeatherSnapshot weather,
  }) {
    return Row(
      children: [
        Icon(
          _weatherIcon(weather.condition),
          color: Colors.white.withValues(alpha: 0.92),
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$title: ${weather.temperature.toStringAsFixed(0)}C, '
            '${weather.rainChance}% chuva, vento ${weather.windSpeed.toStringAsFixed(0)} km/h',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStopsHeader() {
    return Row(
      children: [
        const Icon(Icons.place_outlined, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Paradas da viagem',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (_tripPlan != null)
          Text(
            '${_tripPlan!.totalDistanceKm.toStringAsFixed(0)} km',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  double _mapHeightFor(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width >= 900) {
      return (size.height * 0.58).clamp(420.0, 620.0);
    }
    return (size.height * 0.52).clamp(360.0, 520.0);
  }

  Future<void> _toggleTracking() async {
    final tracking = ref.read(routeTrackingProvider);
    if (tracking == null) return;

    final notifier = ref.read(routeTrackingProvider.notifier);
    try {
      tracking.isTracking
          ? await notifier.stopTracking()
          : await notifier.startTracking();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Nao foi possivel iniciar o GPS. Verifique permissao e localizacao.';
      });
    }
  }

  Future<void> _openFullscreenMap() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: RouteMapWidget(
              fullscreen: true,
              onExpand: () => Navigator.of(context).pop(),
              onToggleTracking: _toggleTracking,
            ),
          ),
        ),
      ),
    );
  }

  IconData _weatherIcon(String condition) {
    return switch (condition) {
      'sunny' => Icons.wb_sunny_rounded,
      'cloudy' => Icons.cloud_rounded,
      'rainy' => Icons.umbrella_rounded,
      'stormy' => Icons.thunderstorm_rounded,
      'snowy' => Icons.ac_unit_rounded,
      _ => Icons.cloud_queue_rounded,
    };
  }

  Widget _buildOriginSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Origem da viagem'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _originModeButton(
                selected: _originMode == OriginMode.currentLocation,
                onTap: () => _changeOriginMode(OriginMode.currentLocation),
                label: 'Minha localização',
              ),
              _originModeButton(
                selected: _originMode == OriginMode.manualCity,
                onTap: () => _changeOriginMode(OriginMode.manualCity),
                label: 'Escolher cidade atual',
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_originMode == OriginMode.currentLocation)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _originPosition == null
                        ? 'Permita localização para usar sua posição atual como ponto de partida.'
                        : 'Localização capturada. Origem pronta para planejar rota.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _loadingOrigin ? null : _requestCurrentLocation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(_loadingOrigin ? 'Carregando...' : 'Permitir'),
                ),
              ],
            )
          else ...[
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _originController,
                onChanged: _onOriginSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar cidade de origem',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.my_location_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            if (_loadingOriginSuggestions)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_originSuggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _originSuggestions.length,
                    itemBuilder: (context, index) {
                      final city = _originSuggestions[index];
                      return ListTile(
                        title: Text(
                          city.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        onTap: () => _selectOriginCity(city),
                      );
                    },
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopsSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Cidades do trajeto'),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _stopController,
              onChanged: _onStopSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Adicionar cidade da rota',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.route_outlined,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
          if (_loadingStopSuggestions)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (_stopSuggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stopSuggestions.length,
                  itemBuilder: (context, index) {
                    final city = _stopSuggestions[index];
                    return ListTile(
                      title: Text(
                        city.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.add, color: Colors.white),
                      onTap: () => _addStop(city),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedRouteOverview() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Rota selecionada'),
          const SizedBox(height: 8),
          _routeItem(
            title: 'Origem',
            subtitle: _originMode == OriginMode.currentLocation
                ? (_originPosition == null
                      ? 'Localização atual ainda não autorizada'
                      : 'Partindo da sua localização atual')
                : (_originCity?.label ?? 'Selecione a cidade atual'),
            icon: Icons.trip_origin,
          ),
          const SizedBox(height: 8),
          if (_selectedStops.isEmpty)
            Text(
              'Adicione as cidades que você vai passar no trajeto.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.5,
              ),
            )
          else
            ..._selectedStops.asMap().entries.map((entry) {
              final index = entry.key;
              final city = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _routeItem(
                  title: 'Parada ${index + 1}',
                  subtitle: city.label,
                  icon: Icons.place_outlined,
                  onRemove: () => _removeStop(city),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _routeItem({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onRemove,
  }) {
    return GlassCard(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String value) {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _originModeButton({
    required bool selected,
    required VoidCallback onTap,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1E3A5F).withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.22),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.96),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
