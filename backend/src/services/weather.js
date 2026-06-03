import fetch from 'node-fetch';

export async function getWeatherForPoint({ lat, lng }) {
  const key = process.env.WEATHER_API_KEY;
  if (!key) throw new Error('WEATHER_API_KEY not configured');

  const url = `https://api.weatherapi.com/v1/current.json?q=${lat},${lng}&key=${key}&aqi=no`;
  const res = await fetch(url);
  const data = await res.json();
  return {
    coordinates: [lat, lng],
    temperature: data?.current?.temp_c ?? null,
    humidity: data?.current?.humidity ?? null,
    windSpeed: data?.current?.wind_kph ?? null,
    condition: data?.current?.condition?.text ?? 'unknown',
    fetchedAt: new Date().toISOString(),
  };
}

export async function getWeatherForPoints(points) {
  return Promise.all(points.map(p => getWeatherForPoint({ lat: p[0], lng: p[1] })));
}
