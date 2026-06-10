// Simple in-memory cache (replace with Redis in production)
const weatherCache = new Map();
const CACHE_TTL_SECONDS = 300; // 5 minutes

export async function getWeatherForPoints(points) {
  return Promise.all(points.map((p) => getWeatherForPoint(p)));
}

export async function getWeatherForPoint(point) {
  const lat = Number(point.lat ?? point[0]);
  const lng = Number(point.lng ?? point[1]);

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    throw new Error('Invalid coordinate');
  }

  const cacheKey = `${lat.toFixed(2)}_${lng.toFixed(2)}`;
  const cached = weatherCache.get(cacheKey);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL_SECONDS * 1000) {
    console.log(`[Weather Cache] Hit for ${cacheKey}`);
    return cached.data;
  }

  console.log(`[Weather] Fetching for ${lat}, ${lng}`);

  try {
    const url = new URL('https://api.open-meteo.com/v1/forecast');
    url.search = new URLSearchParams({
      latitude: lat.toString(),
      longitude: lng.toString(),
      current:
        'temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,weather_code,is_day,wind_speed_10m,uv_index',
      hourly: 'precipitation_probability,weather_code',
      daily: 'precipitation_probability_max',
      timezone: 'auto',
    }).toString();

    const response = await fetch(url, {
      headers: {
        'User-Agent': 'ClimaAgora/1.0 (+https://example.com; contact: dev@climaagora.local)',
      },
    });

    if (!response.ok) {
      throw new Error(`Open-Meteo failed: ${response.status}`);
    }

    const data = await response.json();
    const current = data.current || {};
    const hourly = data.hourly || {};
    const rainChance = resolveRainChance(current.time, hourly);

    const weather = {
      coordinates: [lat, lng],
      temperature: Math.round(Number(current.temperature_2m ?? 25)),
      humidity: Math.round(Number(current.relative_humidity_2m ?? 0)),
      windSpeed: roundOne(Number(current.wind_speed_10m ?? 0)),
      rainChance,
      condition: normalizeCondition(Number(current.weather_code ?? -1)),
      uvIndex: Math.round(Number(current.uv_index ?? 0)),
      fetchedAt: new Date().toISOString(),
    };

    weatherCache.set(cacheKey, {
      data: weather,
      timestamp: Date.now(),
    });

    return weather;
  } catch (error) {
    console.error(`[Weather Error] ${error.message}`);
    return {
      coordinates: [lat, lng],
      temperature: 25,
      humidity: 65,
      windSpeed: 10,
      rainChance: 30,
      condition: 'unknown',
      uvIndex: 5,
      fetchedAt: new Date().toISOString(),
      error: error.message,
    };
  }
}

function resolveRainChance(currentTime, hourly = {}) {
  const times = Array.isArray(hourly.time) ? hourly.time : [];
  const probabilities = Array.isArray(hourly.precipitation_probability)
    ? hourly.precipitation_probability
    : [];

  if (times.length === 0 || probabilities.length === 0) {
    return 0;
  }

  const index = currentTime ? times.indexOf(currentTime) : -1;
  if (index >= 0 && index < probabilities.length) {
    return clamp(Math.round(Number(probabilities[index] ?? 0)), 0, 100);
  }

  return clamp(Math.round(Number(probabilities[0] ?? 0)), 0, 100);
}

function normalizeCondition(code) {
  if (code === 0) return 'sunny';
  if ([1, 2].includes(code)) return 'cloudy';
  if ([3, 45, 48].includes(code)) return 'foggy';
  if ([51, 53, 55, 56, 57, 61, 63, 65, 80, 81, 82].includes(code)) return 'rainy';
  if ([66, 67, 77, 71, 73, 75, 85, 86].includes(code)) return 'snowy';
  if ([95, 96, 99].includes(code)) return 'stormy';
  return 'unknown';
}

function roundOne(value) {
  return Math.round(value * 10) / 10;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}
