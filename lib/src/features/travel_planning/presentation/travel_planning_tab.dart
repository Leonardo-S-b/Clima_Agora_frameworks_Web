import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../weather/domain/city.dart';
import '../../weather/presentation/widgets/glass_card.dart';
import '../data/gemini_activity_api.dart';
import '../data/travel_planning_repository.dart';
import '../domain/trip_plan.dart';
import 'widgets/travel_stop_card.dart';

enum OriginMode { currentLocation, manualCity }

class TravelPlanningTab extends StatefulWidget {
  const TravelPlanningTab({super.key});

  @override
  State<TravelPlanningTab> createState() => _TravelPlanningTabState();
}

class _TravelPlanningTabState extends State<TravelPlanningTab> {
  final _repository = TravelPlanningRepository.create();
  final _aiClient = http.Client();
  late final GeminiActivityApi _aiApi;
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

  @override
  void initState() {
    super.initState();
    _aiApi = GeminiActivityApi(_aiClient);
  }

  @override
  void dispose() {
    _originDebounce?.cancel();
    _stopDebounce?.cancel();
    _originController.dispose();
    _stopController.dispose();
    _repository.dispose();
    _aiApi.dispose();
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
      });
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
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo da viagem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Distância total: ${_tripPlan!.totalDistanceKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Tempo total: ${_formatDuration(_tripPlan!.totalDuration)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._tripPlan!.stops.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '${duration.inMinutes} min';
    }

    return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
  }
}
