import express from 'express';
import crypto from 'crypto';
import { calculateRoute, calculateIntermediatePoints } from '../services/routing.js';
import { getWeatherForPoints } from '../services/weather.js';
import { detectClimaticAlerts } from '../services/alerts.js';

const router = express.Router();

// Store active tracking sessions (in-memory, use Redis in production)
const activeSessions = new Map();

// POST /travel/route-tracking/start
router.post('/start', async (req, res) => {
  try {
    const { originLat, originLng, destinationLat, destinationLng, mode } = req.body;
    if (!originLat || !originLng || !destinationLat || !destinationLng) {
      return res.status(400).json({ error: 'invalid_request', message: 'origin/destination required' });
    }

    const origin = { lat: Number(originLat), lng: Number(originLng) };
    const destination = { lat: Number(destinationLat), lng: Number(destinationLng) };

    // Step 1: Calculate full route and decode polyline
    console.log('[Tracking] Starting route calculation...');
    const routeData = await calculateRoute({ origin, destination, mode: mode || 'driving' });

    // Step 2: Calculate 7 intermediate points distributed along the route
    console.log('[Tracking] Calculating intermediate points...');
    const intermediatePoints = await calculateIntermediatePoints(routeData.points, 7);

    // Step 3: Fetch weather for each intermediate point
    console.log('[Tracking] Fetching weather data...');
    const weatherData = await getWeatherForPoints(
      intermediatePoints.map((p) => ({ lat: p.lat, lng: p.lng }))
    );

    // Enrich intermediate points with weather data
    const pointsWithWeather = intermediatePoints.map((point, idx) => ({
      ...point,
      weather: weatherData[idx],
      estimatedTimeToReach: calculateTimeToPoint(routeData.durationSeconds, idx + 1, intermediatePoints.length),
    }));

    const sessionId = crypto.randomUUID?.() || Date.now().toString();

    // Store session for later updates
    activeSessions.set(sessionId, {
      originLat,
      originLng,
      destinationLat,
      destinationLng,
      mode,
      routePoints: routeData.points,
      intermediatePoints: pointsWithWeather,
      startTime: Date.now(),
      lastWeatherUpdate: Date.now(),
      totalDistanceKm: routeData.distanceMeters / 1000,
      estimatedDurationSeconds: routeData.durationSeconds,
    });

    console.log(`[Tracking] Session created: ${sessionId}, ${pointsWithWeather.length} intermediate points`);

    res.json({
      trackingSessionId: sessionId,
      routePoints: routeData.points,
      intermediatePoints: pointsWithWeather,
      totalDistanceKm: routeData.distanceMeters / 1000,
      estimatedDurationSeconds: routeData.durationSeconds,
    });
  } catch (err) {
    console.error('[Tracking Error]', err.message);
    res.status(500).json({ error: 'server_error', message: String(err.message) });
  }
});

// POST /travel/route-tracking/intermediate-weather
// Fetch updated weather for intermediate points
router.post('/intermediate-weather', async (req, res) => {
  try {
    const { points } = req.body;
    if (!Array.isArray(points) || points.length === 0) {
      return res.status(400).json({ error: 'invalid_request', message: 'points array required' });
    }

    const weather = await getWeatherForPoints(
      points.map((p) => ({ lat: p[0] || p.lat, lng: p[1] || p.lng }))
    );

    res.json({ weather });
  } catch (err) {
    console.error('[Weather Error]', err.message);
    res.status(500).json({ error: 'server_error', message: String(err.message) });
  }
});

// POST /travel/route-tracking/alert-detect
// Detect alert based on weather change
router.post('/alert-detect', async (req, res) => {
  try {
    const { currentWeather, previousWeather, position } = req.body;

    if (!currentWeather) {
      return res.status(400).json({ error: 'invalid_request', message: 'currentWeather required' });
    }

    const alert = detectClimaticAlerts(currentWeather, previousWeather, position);

    res.json({ alert });
  } catch (err) {
    console.error('[Alert Error]', err.message);
    res.status(500).json({ error: 'server_error', message: String(err.message) });
  }
});

// GET /travel/route-tracking/:sessionId/progress
// Get current progress of a tracking session
router.get('/:sessionId/progress', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { lat, lng } = req.query;

    const session = activeSessions.get(sessionId);
    if (!session) {
      return res.status(404).json({ error: 'not_found', message: 'Session not found' });
    }

    if (!lat || !lng) {
      return res.status(400).json({ error: 'invalid_request', message: 'lat, lng required' });
    }

    const userLat = Number(lat);
    const userLng = Number(lng);

    // Calculate progress (simplified)
    const totalDist = session.totalDistanceKm;
    const timeElapsed = (Date.now() - session.startTime) / 1000;
    const estimatedSpeed = totalDist / session.estimatedDurationSeconds; // km/s
    const distTravelled = Math.min(estimatedSpeed * timeElapsed, totalDist);
    const percentComplete = (distTravelled / totalDist) * 100;

    res.json({
      sessionId,
      userPosition: [userLat, userLng],
      percentComplete,
      timeElapsed,
      distanceTravelled: distTravelled,
      nextPointIndex: Math.floor((percentComplete / 100) * session.intermediatePoints.length),
      activeAlert: null,
    });
  } catch (err) {
    console.error('[Progress Error]', err.message);
    res.status(500).json({ error: 'server_error', message: String(err.message) });
  }
});

export default router;

// Helper: Calculate estimated time to reach point
function calculateTimeToPoint(totalDurationSeconds, pointIndex, totalPoints) {
  // Distribute time evenly across points
  const timePerPoint = totalDurationSeconds / (totalPoints + 1);
  return {
    inSeconds: Math.round(timePerPoint * pointIndex),
    inHours: Math.floor((timePerPoint * pointIndex) / 3600),
    inMinutes: Math.floor(((timePerPoint * pointIndex) % 3600) / 60),
  };
}
