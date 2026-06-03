# SPECS Técnicas: Real-Time Route Tracking com Previsão Climática

**Data**: Junho 2026  
**Versão**: 1.0  
**Arquitetura**: Microserviços (Flutter Frontend + Node.js Backend)  

---

## 1. Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                     Flutter Web/Mobile App                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐       │
│  │ Google Maps  │  │ GPS Tracking │  │  Clima Widgets   │       │
│  │   Widget     │  │   (Stream)   │  │   (Animadas)     │       │
│  └──────────────┘  └──────────────┘  └──────────────────┘       │
│         │                 │                     │                 │
└─────────│─────────────────│─────────────────────│────────────────┘
          │                 │                     │
          └─────────────────┼─────────────────────┘
                            │
                    ┌───────▼──────────┐
                    │  Node.js Backend │
                    │  (clima-agora-api)│
                    └───────┬──────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
    ┌───▼────┐         ┌────▼─────┐        ┌───▼──────┐
    │ Google │         │ WeatherAPI│       │ OpenRoute│
    │ Maps   │         │ / OpenW.  │       │ Service  │
    │ API    │         │  (clima)  │       │ (rotas)  │
    └────────┘         └───────────┘       └──────────┘
```

### Componentes Principais

1. **Frontend (Flutter)**
   - Google Maps SDK para renderização
   - Geolocator para GPS tracking
   - Animações customizadas para clima
   - State management (Riverpod ou Bloc)

2. **Backend (Node.js)**
   - API REST para cálculo de pontos intermediários
   - Proxy para WeatherAPI
   - Cache de previsões climáticas
   - WebSocket para updatos em tempo real (Fase 2)

3. **Serviços Externos**
   - Google Maps API (Maps, Routes)
   - WeatherAPI ou OpenWeatherMap
   - OpenRouteService (rotas alternativas)

---

## 2. SPEC Frontend: Flutter

### 2.1 Pacotes Necessários

```yaml
# pubspec.yaml
dependencies:
  google_maps_flutter: ^2.10.0        # Maps rendering
  geolocator: ^11.0.0                  # GPS tracking
  permission_handler: ^11.4.3           # Android/iOS permissions
  geocoding: ^2.1.1                    # Lat/lng ↔ address
  http: ^1.1.0                         # API calls
  riverpod: ^2.4.0                     # State management
  riverpod_generator: ^2.3.0            # Code generation
  freezed_annotation: ^2.4.1            # Models
  lottie: ^2.6.0                       # Animações (opcional)
  location: ^5.0.0                     # Alternativa ao geolocator
  flutter_local_notifications: ^14.1.0 # Notificações/Alertas
  intl: ^0.19.0                        # Formatação data/hora
  google_maps_flutter_platform_interface: ^2.10.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  freezed: ^2.4.1
  build_runner: ^2.4.0
```

### 2.2 Models (Freezed)

```dart
// lib/models/route_tracking.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_tracking.freezed.dart';
part 'route_tracking.g.dart';

@freezed
class RouteTrackingState with _$RouteTrackingState {
  const factory RouteTrackingState({
    required LatLng userPosition,
    required List<LatLng> routePoints,
    required List<IntermediatePoint> intermediatePoints,
    required RouteProgress progress,
    required ClimateAlert? activeAlert,
    required bool isTracking,
    required DateTime startedAt,
  }) = _RouteTrackingState;
}

@freezed
class IntermediatePoint with _$IntermediatePoint {
  const factory IntermediatePoint({
    required int index,
    required LatLng coordinates,
    required String label,
    required WeatherSnapshot weather,
    required double distanceFromStart,
    required Duration estimatedTimeToReach,
    required List<ActivitySuggestion> suggestedActivities,
  }) = _IntermediatePoint;
}

@freezed
class WeatherSnapshot with _$WeatherSnapshot {
  const factory WeatherSnapshot({
    required double temperature,
    required int humidity,
    required double windSpeed,
    required int rainChance,
    required String condition,        // "sunny", "cloudy", "rainy", "stormy"
    required int uvIndex,
    required DateTime fetchedAt,
  }) = _WeatherSnapshot;
}

@freezed
class RouteProgress with _$RouteProgress {
  const factory RouteProgress({
    required double percentComplete,
    required Duration timeElapsed,
    required Duration estimatedTimeRemaining,
    required double distanceTravelledKm,
    required double totalDistanceKm,
    required int nextIntermediatePointIndex,
  }) = _RouteProgress;
}

@freezed
class ClimateAlert with _$ClimateAlert {
  const factory ClimateAlert({
    required AlertSeverity severity,    // LOW, MEDIUM, HIGH, CRITICAL
    required String title,
    required String description,
    required DateTime timestamp,
    required String? suggestedAction,
  }) = _ClimateAlert;
}

enum AlertSeverity { LOW, MEDIUM, HIGH, CRITICAL }
```

### 2.3 State Management (Riverpod)

```dart
// lib/providers/route_tracking_provider.dart

import 'package:riverpod/riverpod.dart';
import 'package:geolocator/geolocator.dart';

final routeTrackingProvider = StateNotifierProvider<
    RouteTrackingNotifier,
    RouteTrackingState>((ref) {
  return RouteTrackingNotifier(
    ref.watch(locationServiceProvider),
    ref.watch(weatherServiceProvider),
  );
});

final userLocationStreamProvider = StreamProvider<Position>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);
  yield* locationService.getPositionStream();
});

final intermediatePointsProvider = FutureProvider<List<IntermediatePoint>>((ref) async {
  final routeService = ref.watch(routeServiceProvider);
  final weatherService = ref.watch(weatherServiceProvider);
  
  final origin = ref.watch(routeTrackingProvider).userPosition;
  final destination = ref.watch(destinationProvider);
  
  return routeService.calculateIntermediatePoints(
    origin: origin,
    destination: destination,
    weatherService: weatherService,
  );
});

final weatherUpdatesProvider = StreamProvider<List<WeatherSnapshot>>((ref) async* {
  final tracking = ref.watch(routeTrackingProvider);
  final weatherService = ref.watch(weatherServiceProvider);
  
  // Atualizar clima a cada 5 minutos
  while (tracking.isTracking) {
    final updates = await Future.wait(
      tracking.intermediatePoints.map(
        (point) => weatherService.getWeather(point.coordinates),
      ),
    );
    yield updates;
    await Future.delayed(Duration(minutes: 5));
  }
});

final climateAlertsProvider = StreamProvider<ClimateAlert?>((ref) async* {
  final weatherStream = ref.watch(weatherUpdatesProvider);
  
  weatherStream.when(
    data: (weatherUpdates) {
      final alerts = _detectAlerts(weatherUpdates);
      if (alerts.isNotEmpty) {
        yield alerts.first; // Maior severidade
      }
    },
    error: (err, stack) => null,
    loading: () => null,
  );
});

class RouteTrackingNotifier extends StateNotifier<RouteTrackingState> {
  final LocationService _locationService;
  final WeatherService _weatherService;
  
  RouteTrackingNotifier(this._locationService, this._weatherService)
    : super(/* initial state */);
  
  Future<void> startTracking(LatLng destination) async {
    state = state.copyWith(isTracking: true, startedAt: DateTime.now());
    _locationService.startTracking();
  }
  
  void stopTracking() {
    state = state.copyWith(isTracking: false);
    _locationService.stopTracking();
  }
}
```

### 2.4 Google Maps Widget

```dart
// lib/widgets/route_map_widget.dart

class RouteMapWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(routeTrackingProvider);
    
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: tracking.userPosition,
        zoom: 14,
      ),
      polylines: _buildPolylines(tracking),
      markers: _buildMarkers(tracking),
      onCameraMove: (CameraPosition pos) {
        // Handle camera movement
      },
    );
  }
  
  Set<Polyline> _buildPolylines(RouteTrackingState tracking) {
    return {
      Polyline(
        polylineId: PolylineId('route'),
        points: tracking.routePoints,
        color: Colors.blue,
        width: 5,
        geodesic: true,
      ),
    };
  }
  
  Set<Marker> _buildMarkers(RouteTrackingState tracking) {
    final markers = <Marker>{};
    
    // User position marker
    markers.add(
      Marker(
        markerId: MarkerId('user'),
        position: tracking.userPosition,
        icon: BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(32, 32)),
          'assets/user_marker.png',
        ),
      ),
    );
    
    // Intermediate points with weather
    for (var point in tracking.intermediatePoints) {
      markers.add(
        Marker(
          markerId: MarkerId('point_${point.index}'),
          position: point.coordinates,
          infoWindow: InfoWindow(
            title: point.label,
            snippet: '${point.weather.temperature}°C - ${point.weather.condition}',
          ),
          icon: _getWeatherIcon(point.weather),
        ),
      );
    }
    
    return markers;
  }
  
  BitmapDescriptor _getWeatherIcon(WeatherSnapshot weather) {
    final iconAsset = switch (weather.condition) {
      'sunny' => 'assets/weather/sun.png',
      'cloudy' => 'assets/weather/cloud.png',
      'rainy' => 'assets/weather/rain.png',
      'stormy' => 'assets/weather/storm.png',
      _ => 'assets/weather/unknown.png',
    };
    
    return BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(40, 40)),
      iconAsset,
    );
  }
}
```

### 2.5 Clima Balões Animados

```dart
// lib/widgets/weather_balloon_overlay.dart

class WeatherBalloonOverlay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intermediatePoints = ref.watch(intermediatePointsProvider);
    
    return intermediatePoints.when(
      data: (points) => Stack(
        children: [
          ...points.map((point) => _buildBalloon(point)).toList(),
        ],
      ),
      loading: () => SizedBox.shrink(),
      error: (err, st) => SizedBox.shrink(),
    );
  }
  
  Widget _buildBalloon(IntermediatePoint point) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_animation.value * pi) * 10),
          child: Container(
            decoration: BoxDecoration(
              color: _getColorByCondition(point.weather.condition),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getWeatherIcon(point.weather), size: 24),
                  Text('${point.weather.temperature}°C', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _getColorByCondition(String condition) {
    return switch (condition) {
      'sunny' => Colors.orange.withOpacity(0.8),
      'cloudy' => Colors.grey.withOpacity(0.8),
      'rainy' => Colors.blue.withOpacity(0.8),
      'stormy' => Colors.red.withOpacity(0.8),
      _ => Colors.grey.withOpacity(0.8),
    };
  }
}
```

### 2.6 Timeline Visual

```dart
// lib/widgets/route_timeline.dart

class RouteTimeline extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(intermediatePointsProvider);
    
    return points.when(
      data: (intermediatePoints) => ListView.builder(
        itemCount: intermediatePoints.length,
        itemBuilder: (context, index) {
          final point = intermediatePoints[index];
          return TimelineItem(
            point: point,
            isLast: index == intermediatePoints.length - 1,
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Erro ao carregar timeline')),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final IntermediatePoint point;
  final bool isLast;
  
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getColorByCondition(point.weather.condition),
                child: Icon(_getWeatherIcon(point.weather), color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: Colors.grey[300]),
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${point.estimatedTimeToReach.inHours}h ${point.estimatedTimeToReach.inMinutes % 60}m',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  '${point.weather.temperature}°C, ${point.weather.condition}',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: point.suggestedActivities
                      .take(3)
                      .map((activity) => Chip(
                        label: Text(activity.name, style: TextStyle(fontSize: 10)),
                        padding: EdgeInsets.symmetric(horizontal: 4),
                      ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.7 Permissões & Inicialização

```dart
// lib/services/location_service.dart

class LocationService {
  Future<void> requestPermissions() async {
    final permissionStatus = await Geolocator.requestLocationPermission();
    if (permissionStatus == LocationPermission.denied) {
      throw Exception('Permissão de localização negada');
    }
    if (permissionStatus == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
    }
  }
  
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // 10 metros
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}
```

---

## 3. SPEC Backend: Node.js

### 3.1 Novos Endpoints

#### POST /travel/route-tracking/start
Inicia sessão de tracking

```
Request:
{
  "originLat": -23.5505,
  "originLng": -46.6333,
  "destinationLat": -22.9068,
  "destinationLng": -43.1729,
  "mode": "driving" | "walking" | "bicycling"
}

Response:
{
  "trackingSessionId": "uuid",
  "routePoints": [[lat, lng], ...],
  "intermediatePoints": [{
    "index": 1,
    "coordinates": [lat, lng],
    "label": "São Vicente",
    "distanceFromStart": 50.5,
    "estimatedTimeToReach": 3600
  }, ...],
  "totalDistanceKm": 250,
  "estimatedDurationSeconds": 14400
}
```

#### POST /travel/route-tracking/intermediate-weather
Busca clima para pontos intermediários

```
Request:
{
  "points": [[lat, lng], ...]
}

Response:
{
  "weather": [{
    "coordinates": [lat, lng],
    "temperature": 28,
    "humidity": 65,
    "windSpeed": 12,
    "rainChance": 30,
    "condition": "cloudy",
    "uvIndex": 7,
    "fetchedAt": "2026-06-03T14:30:00Z"
  }, ...]
}
```

#### POST /travel/route-tracking/activities-at-point
Gera sugestões para ponto específico

```
Request:
{
  "pointLat": -23.0,
  "pointLng": -46.5,
  "weather": {
    "temperature": 28,
    "condition": "rainy"
  },
  "time": "2026-06-03T14:30:00Z"
}

Response:
{
  "activities": [{
    "id": "act_123",
    "name": "Museu de Arte",
    "type": "indoor",
    "suitability": 0.95,
    "reason": "Clima inadequado para atividades externas"
  }, ...]
}
```

#### GET /travel/route-tracking/:sessionId/progress
Rastreia progresso em tempo real (WebSocket alternativo)

```
Request: GET /travel/route-tracking/abc123/progress?lat=-23.5&lng=-46.6

Response:
{
  "sessionId": "abc123",
  "userPosition": [-23.5, -46.6],
  "percentComplete": 45,
  "timeElapsed": 7200,
  "distanceTravelled": 112.5,
  "nextPointIndex": 3,
  "activeAlert": null
}
```

#### POST /travel/route-tracking/alert-detect
Detecta alertas climáticos

```
Request:
{
  "currentWeather": {...},
  "previousWeather": {...},
  "position": [lat, lng]
}

Response:
{
  "alert": {
    "severity": "HIGH",
    "title": "Chuva forte detectada",
    "description": "Mudança significativa em 15 min",
    "suggestedAction": "Procurar abrigo"
  }
}
```

### 3.2 Implementação Backend

```javascript
// backend/src/routes/tracking.js

import express from 'express';
import { calculateIntermediatePoints } from '../services/routing.js';
import { getWeatherForPoints } from '../services/weather.js';
import { generateActivities } from '../services/activities.js';
import { detectClimaticAlerts } from '../services/alerts.js';

const router = express.Router();

// Sessões ativas (em produção, usar Redis)
const activeSessions = new Map();

router.post('/start', async (req, res) => {
  try {
    const { originLat, originLng, destinationLat, destinationLng, mode } = req.body;
    
    // Calcular rota usando Google Maps API
    const routeData = await calculateRoute({
      origin: { lat: originLat, lng: originLng },
      destination: { lat: destinationLat, lng: destinationLng },
      mode
    });
    
    // Calcular pontos intermediários
    const intermediatePoints = await calculateIntermediatePoints(
      routeData.points,
      7 // 7 pontos
    );
    
    // Buscar clima para cada ponto
    const weatherData = await getWeatherForPoints(
      intermediatePoints.map(p => ({ lat: p.lat, lng: p.lng }))
    );
    
    // Gerar sugestões iniciais
    const pointsWithActivities = await Promise.all(
      intermediatePoints.map(async (point, idx) => ({
        ...point,
        weather: weatherData[idx],
        suggestedActivities: await generateActivities({
          location: { lat: point.lat, lng: point.lng },
          weather: weatherData[idx],
          timeOfDay: 'afternoon'
        })
      }))
    );
    
    const sessionId = crypto.randomUUID();
    activeSessions.set(sessionId, {
      originLat,
      originLng,
      destinationLat,
      destinationLng,
      mode,
      routePoints: routeData.points,
      intermediatePoints: pointsWithActivities,
      startTime: Date.now(),
      lastWeatherUpdate: Date.now()
    });
    
    res.json({
      trackingSessionId: sessionId,
      routePoints: routeData.points,
      intermediatePoints: pointsWithActivities,
      totalDistanceKm: routeData.distanceMeters / 1000,
      estimatedDurationSeconds: routeData.durationSeconds
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/intermediate-weather', async (req, res) => {
  try {
    const { points } = req.body;
    
    const weather = await Promise.all(
      points.map(([lat, lng]) => 
        getWeatherForPoint({ lat, lng })
      )
    );
    
    res.json({ weather });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/activities-at-point', async (req, res) => {
  try {
    const { pointLat, pointLng, weather, time } = req.body;
    
    const activities = await generateActivities({
      location: { lat: pointLat, lng: pointLng },
      weather,
      timeOfDay: new Date(time).getHours() < 12 ? 'morning' : 'afternoon'
    });
    
    res.json({ activities });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/alert-detect', async (req, res) => {
  try {
    const { currentWeather, previousWeather, position } = req.body;
    
    const alert = detectClimaticAlerts(
      currentWeather,
      previousWeather,
      position
    );
    
    res.json({ alert });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
```

### 3.3 Serviços Backend

```javascript
// backend/src/services/routing.js

import polyline from '@mapbox/polyline';

export async function calculateRoute(params) {
  const { origin, destination, mode } = params;
  
  const response = await fetch(
    `https://maps.googleapis.com/maps/api/directions/json?` +
    `origin=${origin.lat},${origin.lng}&` +
    `destination=${destination.lat},${destination.lng}&` +
    `mode=${mode}&` +
    `key=${process.env.GOOGLE_MAPS_API_KEY}`
  );
  
  const data = await response.json();
  const route = data.routes[0];
  
  // Decodificar polyline
  const points = polyline.decode(route.overview_polyline.points)
    .map(([lat, lng]) => ({ lat, lng }));
  
  return {
    points,
    distanceMeters: route.legs.reduce((sum, leg) => sum + leg.distance.value, 0),
    durationSeconds: route.legs.reduce((sum, leg) => sum + leg.duration.value, 0)
  };
}

export async function calculateIntermediatePoints(routePoints, numPoints) {
  const step = Math.floor(routePoints.length / (numPoints + 1));
  const intermediate = [];
  
  for (let i = 1; i <= numPoints; i++) {
    const point = routePoints[i * step];
    intermediate.push({
      index: i,
      lat: point.lat,
      lng: point.lng,
      label: `Ponto ${i}` // Será geocodificado
    });
  }
  
  // Geocodificar para obter nomes
  return Promise.all(
    intermediate.map(async (point) => ({
      ...point,
      label: await geocodePoint(point)
    }))
  );
}
```

```javascript
// backend/src/services/weather.js

export async function getWeatherForPoints(points) {
  return Promise.all(
    points.map(point => getWeatherForPoint(point))
  );
}

export async function getWeatherForPoint(point) {
  // Cache de 5 minutos
  const cacheKey = `weather:${point.lat.toFixed(2)}:${point.lng.toFixed(2)}`;
  const cached = await redis.get(cacheKey);
  
  if (cached) return JSON.parse(cached);
  
  const response = await fetch(
    `https://api.weatherapi.com/v1/current.json?` +
    `q=${point.lat},${point.lng}&` +
    `key=${process.env.WEATHER_API_KEY}&` +
    `aqi=yes`
  );
  
  const data = await response.json();
  
  const weather = {
    coordinates: [point.lat, point.lng],
    temperature: Math.round(data.current.temp_c),
    humidity: data.current.humidity,
    windSpeed: data.current.wind_kph,
    rainChance: data.forecast.forecastday[0].day.daily_chance_of_rain,
    condition: normalizeCondition(data.current.condition.text),
    uvIndex: Math.round(data.current.uv),
    fetchedAt: new Date().toISOString()
  };
  
  await redis.setex(cacheKey, 300, JSON.stringify(weather)); // 5 min cache
  
  return weather;
}

function normalizeCondition(text) {
  const lower = text.toLowerCase();
  if (lower.includes('rain') || lower.includes('shower')) return 'rainy';
  if (lower.includes('storm') || lower.includes('thunder')) return 'stormy';
  if (lower.includes('cloud')) return 'cloudy';
  if (lower.includes('sun') || lower.includes('clear')) return 'sunny';
  return 'unknown';
}
```

```javascript
// backend/src/services/alerts.js

export function detectClimaticAlerts(current, previous, position) {
  const tempDiff = Math.abs(current.temperature - previous.temperature);
  const windDiff = current.windSpeed - previous.windSpeed;
  const rainDiff = current.rainChance - previous.rainChance;
  
  // Detectar queda de temperatura
  if (tempDiff > 5) {
    return {
      severity: tempDiff > 10 ? 'HIGH' : 'MEDIUM',
      title: 'Mudança de temperatura',
      description: `Temperatura caiu ${tempDiff.toFixed(1)}°C`,
      suggestedAction: 'Ajuste roupas e hidratação'
    };
  }
  
  // Detectar aumento de chuva
  if (rainDiff > 30) {
    return {
      severity: current.rainChance > 70 ? 'HIGH' : 'MEDIUM',
      title: 'Risco de chuva aumentou',
      description: `Chance de chuva: ${current.rainChance}%`,
      suggestedAction: 'Procure abrigo'
    };
  }
  
  // Detectar vento forte
  if (current.windSpeed > 30) {
    return {
      severity: current.windSpeed > 50 ? 'CRITICAL' : 'HIGH',
      title: 'Vento forte detectado',
      description: `Velocidade do vento: ${current.windSpeed} km/h`,
      suggestedAction: 'Busque abrigo seguro'
    };
  }
  
  return null;
}
```

### 3.4 Enviroment Variables

```bash
# .env (backend)
GOOGLE_MAPS_API_KEY=xxxx
WEATHER_API_KEY=xxxx
OPEN_ROUTE_SERVICE_KEY=xxxx
REDIS_URL=redis://localhost:6379
NODE_ENV=production
PORT=8787
```

---

## 4. Arquitetura de Dados & Cache

### 4.1 Schema Redis

```
# Session data (TTL: 24h)
tracking:session:{sessionId} → {
  originLat, originLng, destinationLat, destinationLng,
  mode, routePoints[], intermediatePoints[], startTime
}

# Weather cache (TTL: 5 min)
weather:{lat}:{lng} → { temperature, humidity, ... }

# Activities cache (TTL: 30 min)
activities:{lat}:{lng}:{condition}:{hour} → [...]
```

### 4.2 Otimizações

- **Previsão offline**: Cache de 1 hora de clima antes de viagem
- **Batching de requests**: Agrupar múltiplos pontos em 1 chamada
- **Circuit breaker**: Se WeatherAPI falhar, usar fallback local
- **Rate limiting**: 1 update de clima/ponto a cada 5 minutos

---

## 5. Fluxo de Dados em Tempo Real

```
Flutter App                    Backend                  Apis Externas
    │                            │                          │
    ├─ Start tracking ──────────>│                          │
    │                            ├─ Calculate route ──────->│ Google Maps
    │                            │<──────────────────────────┤
    │<───── Route + Points ───────┤                          │
    │                            │                          │
    ├─ Get weather ─────────────>│                          │
    │                            ├─ Fetch weather ────────>│ WeatherAPI
    │                            │<────────────────────────┤
    │<──── Weather/Activities ────┤                          │
    │                            │                          │
    ├─ Stream position ─────────>│                          │
    │ (every 20s)               │                          │
    │                            ├─ Calculate progress     │
    │                            ├─ Detect alerts         │
    │                            ├─ Generate suggestions  │
    │                            │                         │
    │<─── Updates (pos, alerts) ─┤                          │
    │                            │                          │
    └─ Stop tracking ───────────>│                          │
                                 ├─ Save session history   │
```

---

## 6. Performance & Scalability

### Métricas Alvo

| Métrica | Alvo |
|---------|------|
| Latência rota | <500ms |
| Latência clima | <1s |
| Atualização posição | <2s |
| Memory/session | <5MB |
| Suportar | 10k sessões simultâneas |

### Estratégias

1. **Caching multi-layer**:
   - CDN para Google Maps tiles
   - Redis para clima/atividades
   - Local storage para 1 hora offline

2. **Compressão**:
   - Gzip para responses
   - Polyline encoding para rotas

3. **Lazy loading**:
   - Carregar atividades ao chegar perto
   - Clima atualiza a cada 5 min (não continuamente)

4. **Escalabilidade**:
   - Load balancer para múltiplas instâncias backend
   - Redis cluster para cache distribuído
   - Database read replicas para histórico

---

## 7. Segurança

- ✅ API keys nunca no frontend (proxy backend)
- ✅ Rate limiting: 100 req/min por sessão
- ✅ HTTPS obrigatório
- ✅ Validar input: lat/lng range, mode enum
- ✅ Session timeout: 12h
- ✅ CORS restrito a domínios autorizados

---

## 8. Testing Strategy

### Unit Tests
- Cálculo de pontos intermediários
- Detecção de alertas
- Normalização de clima

### Integration Tests
- Start → Get weather → Track → Stop
- Alertas disparados corretamente
- Cache funcionando

### E2E Tests
- Usuário inicia tracking → navega mapa → recebe alertas
- Web e mobile

### Load Tests
- 1000 sessões simultâneas
- 100 req/s para weather API

---

## 9. Roadmap Implementação

### Sprint 1 (Semana 1-2)
- [ ] Setup Google Maps SDK
- [ ] GPS tracking básico
- [ ] Cálculo de pontos intermediários
- [ ] Integração WeatherAPI

### Sprint 2 (Semana 3-4)
- [ ] Balões de clima no mapa
- [ ] Timeline visual
- [ ] Sugestões por ponto

### Sprint 3 (Semana 5-6)
- [ ] Alertas de risco
- [ ] Histórico & replay
- [ ] Otimizações de performance

### Sprint 4 (Semana 7-8)
- [ ] Testes e2e
- [ ] Publicação MVP
- [ ] Monitoramento em produção

