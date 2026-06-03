import fetch from 'node-fetch';
import polyline from '@mapbox/polyline';

export async function calculateRoute({ origin, destination, mode = 'driving' }) {
  // Use Google Directions API to fetch route (requires API key in env)
  const key = process.env.GOOGLE_MAPS_API_KEY;
  if (!key) throw new Error('GOOGLE_MAPS_API_KEY not configured');

  const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin.lat},${origin.lng}&destination=${destination.lat},${destination.lng}&mode=${mode}&key=${key}`;
  const res = await fetch(url);
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Google Directions API failed: ${res.status} ${text.slice(0, 200)}`);
  }

  const data = await res.json();
  if (!data.routes || data.routes.length === 0) {
    throw new Error('No route found');
  }

  const route = data.routes[0];

  // Decode overview polyline to get full route points
  let decodedPoints = [];
  if (route.overview_polyline?.points) {
    decodedPoints = polyline.decode(route.overview_polyline.points).map(([lat, lng]) => ({
      lat,
      lng,
    }));
  }

  // If decode fails or polyline is missing, fall back to start/end
  if (decodedPoints.length === 0) {
    decodedPoints = [
      { lat: origin.lat, lng: origin.lng },
      { lat: destination.lat, lng: destination.lng },
    ];
  }

  const distanceMeters = route.legs.reduce((s, l) => s + (l.distance?.value || 0), 0);
  const durationSeconds = route.legs.reduce((s, l) => s + (l.duration?.value || 0), 0);

  return {
    points: decodedPoints,
    distanceMeters,
    durationSeconds,
  };
}

export async function calculateIntermediatePoints(routePoints, numPoints = 7) {
  if (!routePoints || routePoints.length < 2) {
    throw new Error('Route must have at least 2 points');
  }

  // Calculate step size to distribute points evenly along route
  const step = Math.floor((routePoints.length - 1) / (numPoints + 1));
  const intermediatePoints = [];

  for (let i = 1; i <= numPoints; i++) {
    const pointIndex = Math.min(i * step, routePoints.length - 1);
    const point = routePoints[pointIndex];

    intermediatePoints.push({
      index: i,
      lat: point.lat,
      lng: point.lng,
      label: `Ponto ${i}`, // Will be geocoded later if needed
      distanceFromStart: calculateDistanceUpTo(routePoints, pointIndex),
    });
  }

  return intermediatePoints;
}

// Calculate cumulative distance up to a given point index
function calculateDistanceUpTo(routePoints, upToIndex) {
  if (upToIndex <= 0) return 0;

  let totalKm = 0;
  for (let i = 0; i < upToIndex; i++) {
    const p1 = routePoints[i];
    const p2 = routePoints[i + 1];
    totalKm += haversineDistance(p1.lat, p1.lng, p2.lat, p2.lng);
  }

  return totalKm;
}

// Haversine formula to calculate distance between two coordinates (in km)
function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
