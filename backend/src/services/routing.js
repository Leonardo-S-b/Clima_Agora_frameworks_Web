import fetch from 'node-fetch';

export async function calculateRoute({ origin, destination, mode = 'driving' }) {
  // Minimal implementation using Google Directions (requires API key in env)
  const key = process.env.GOOGLE_MAPS_API_KEY;
  if (!key) throw new Error('GOOGLE_MAPS_API_KEY not configured');

  const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin.lat},${origin.lng}&destination=${destination.lat},${destination.lng}&mode=${mode}&key=${key}`;
  const res = await fetch(url);
  const data = await res.json();
  if (!data.routes || data.routes.length === 0) throw new Error('No route found');

  const route = data.routes[0];
  // Simplified: return overview polyline and basic metrics
  return {
    points: [],
    distanceMeters: route.legs.reduce((s, l) => s + (l.distance?.value || 0), 0),
    durationSeconds: route.legs.reduce((s, l) => s + (l.duration?.value || 0), 0),
  };
}
