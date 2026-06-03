import fetch from 'node-fetch';

// Simple in-memory cache (replace with Redis in production)
const weatherCache = new Map();
const CACHE_TTL_SECONDS = 300; // 5 minutes

export async function getWeatherForPoints(points) {
  return Promise.all(points.map((p) => getWeatherForPoint(p)));
}

export async function getWeatherForPoint(point) {
  const lat = point.lat || point[0];
  const lng = point.lng || point[1];

  // Check cache
  const cacheKey = `${Math.round(lat * 100)}_${Math.round(lng * 100)}`;
  const cached = weatherCache.get(cacheKey);

  if (cached && Date.now() - cached.timestamp < CACHE_TTL_SECONDS * 1000) {
    console.log(`[Weather Cache] Hit for ${cacheKey}`);
    return cached.data;
  }

  console.log(`[Weather] Fetching for ${lat}, ${lng}`);

  const key = process.env.WEATHER_API_KEY;
  if (!key) {
    throw new Error('WEATHER_API_KEY not configured');
  }

  try {
    const url = `https://api.weatherapi.com/v1/current.json?q=${lat},${lng}&key=${key}&aqi=yes`;
    const res = await fetch(url);

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`WeatherAPI failed: ${res.status} ${text.slice(0, 200)}`);
    }

    const data = await res.json();

    const weather = {
      coordinates: [lat, lng],
      temperature: Math.round(data.current.temp_c),
      humidity: data.current.humidity,
      windSpeed: data.current.wind_kph,
      rainChance:
        data.forecast?.forecastday?.[0]?.day?.daily_chance_of_rain || data.current.chance_of_rain || 0,
      condition: normalizeCondition(data.current.condition.text),
      uvIndex: Math.round(data.current.uv),
      fetchedAt: new Date().toISOString(),
    };

    // Cache the result
    weatherCache.set(cacheKey, {
      data: weather,
      timestamp: Date.now(),
    });

    return weather;
  } catch (error) {
    console.error(`[Weather Error] ${error.message}`);
    // Return fallback weather if API fails
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

function normalizeCondition(text) {
  if (!text) return 'unknown';

  const lower = text.toLowerCase();

  if (lower.includes('rain') || lower.includes('shower')) return 'rainy';
  if (lower.includes('storm') || lower.includes('thunder')) return 'stormy';
  if (lower.includes('cloud')) return 'cloudy';
  if (lower.includes('sun') || lower.includes('clear') || lower.includes('sunny')) return 'sunny';
  if (lower.includes('fog') || lower.includes('mist')) return 'foggy';
  if (lower.includes('snow')) return 'snowy';

  return 'unknown';
}
