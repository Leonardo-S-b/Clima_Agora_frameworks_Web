import polyline from '@mapbox/polyline';

const OSRM_PROFILE_BY_MODE = {
  driving: 'driving',
  bicycling: 'bike',
  walking: 'foot',
};

export async function calculateRoute({ origin, destination, mode = 'driving' }) {
  const profile = normalizeProfile(mode);
  const coordinates = `${origin.lng},${origin.lat};${destination.lng},${destination.lat}`;
  const url =
    `https://router.project-osrm.org/route/v1/${profile}/${coordinates}` +
    '?overview=full&geometries=polyline&steps=false';

  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'ClimaAgora/1.0 (+https://example.com; contact: dev@climaagora.local)',
      },
    });

    if (!response.ok) {
      throw new Error(`OSRM failed: ${response.status}`);
    }

    const data = await response.json();
    const route = data?.routes?.[0];
    if (!route) {
      throw new Error(`Route not found: ${data?.code || 'unknown'}`);
    }

    const points =
      route.geometry && typeof route.geometry === 'string'
        ? polyline.decode(route.geometry).map(([lat, lng]) => ({ lat, lng }))
        : [];

    return {
      points: points.length > 0 ? points : buildFallbackRoute(origin, destination),
      distanceMeters: Math.round(route.distance || 0),
      durationSeconds: Math.round(route.duration || 0),
      profile,
    };
  } catch (error) {
    console.log(`[Routing] OSRM failed: ${error.message}. Using fallback route.`);
    const points = buildFallbackRoute(origin, destination);

    return {
      points,
      distanceMeters: Math.round(calculateRouteDistanceKm(points) * 1000),
      durationSeconds: Math.round(calculateRouteDistanceKm(points) * 120),
      profile,
    };
  }
}

export async function calculateIntermediatePoints(routePoints, numPoints = 5) {
  if (!Array.isArray(routePoints) || routePoints.length < 2) {
    throw new Error('Route must have at least 2 points');
  }

  const cumulativeDistances = buildCumulativeDistances(routePoints);
  const totalDistanceKm = cumulativeDistances[cumulativeDistances.length - 1] || 0;
  const intermediatePoints = [];

  for (let i = 1; i <= numPoints; i++) {
    const targetDistanceKm = (totalDistanceKm * i) / (numPoints + 1);
    const coordinates = interpolatePointAtDistance(routePoints, cumulativeDistances, targetDistanceKm);
    const label = await geocodePoint(coordinates, i);

    intermediatePoints.push({
      index: i,
      lat: coordinates.lat,
      lng: coordinates.lng,
      label,
      distanceFromStart: roundKm(targetDistanceKm),
    });
  }

  return intermediatePoints;
}

export async function geocodePoint(point, index = 1) {
  try {
    const url =
      `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.lat}&lon=${point.lng}` +
      '&zoom=12&addressdetails=1';

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'ClimaAgora/1.0 (+https://example.com; contact: dev@climaagora.local)',
        Accept: 'application/json',
      },
    });

    if (!response.ok) {
      return `Ponto ${index}`;
    }

    const data = await response.json();
    const address = data?.address || {};
    const label =
      address.city ||
      address.town ||
      address.village ||
      address.suburb ||
      address.county ||
      address.state ||
      data?.name ||
      data?.display_name ||
      `Ponto ${index}`;

    return String(label).split(',')[0].trim() || `Ponto ${index}`;
  } catch {
    return `Ponto ${index}`;
  }
}

function normalizeProfile(mode) {
  const key = String(mode || 'driving').toLowerCase();
  return OSRM_PROFILE_BY_MODE[key] || 'driving';
}

function buildFallbackRoute(origin, destination, segments = 12) {
  const points = [{ lat: origin.lat, lng: origin.lng }];

  for (let i = 1; i < segments; i += 1) {
    const ratio = i / segments;
    points.push({
      lat: origin.lat + (destination.lat - origin.lat) * ratio,
      lng: origin.lng + (destination.lng - origin.lng) * ratio,
    });
  }

  points.push({ lat: destination.lat, lng: destination.lng });
  return points;
}

function calculateRouteDistanceKm(points) {
  return points.slice(1).reduce((sum, point, index) => {
    const previous = points[index];
    return sum + haversineDistance(previous.lat, previous.lng, point.lat, point.lng);
  }, 0);
}

function buildCumulativeDistances(routePoints) {
  const cumulative = [0];

  for (let i = 1; i < routePoints.length; i += 1) {
    const previous = routePoints[i - 1];
    const current = routePoints[i];
    const nextDistance =
      cumulative[i - 1] + haversineDistance(previous.lat, previous.lng, current.lat, current.lng);
    cumulative.push(nextDistance);
  }

  return cumulative;
}

function interpolatePointAtDistance(routePoints, cumulativeDistances, targetDistanceKm) {
  const totalDistanceKm = cumulativeDistances[cumulativeDistances.length - 1] || 0;

  if (totalDistanceKm === 0 || targetDistanceKm <= 0) {
    return routePoints[0];
  }

  if (targetDistanceKm >= totalDistanceKm) {
    return routePoints[routePoints.length - 1];
  }

  for (let i = 1; i < cumulativeDistances.length; i += 1) {
    const startDistance = cumulativeDistances[i - 1];
    const endDistance = cumulativeDistances[i];

    if (targetDistanceKm <= endDistance) {
      const span = endDistance - startDistance || 1;
      const ratio = (targetDistanceKm - startDistance) / span;
      const start = routePoints[i - 1];
      const end = routePoints[i];

      return {
        lat: start.lat + (end.lat - start.lat) * ratio,
        lng: start.lng + (end.lng - start.lng) * ratio,
      };
    }
  }

  return routePoints[routePoints.length - 1];
}

function haversineDistance(lat1, lng1, lat2, lng2) {
  const R = 6371;
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

function roundKm(value) {
  return Math.round(value * 10) / 10;
}
