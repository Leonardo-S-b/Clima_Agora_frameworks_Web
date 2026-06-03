export function detectClimaticAlerts(currentWeather, previousWeather, position) {
  if (!previousWeather) {
    return null; // No alert on first measurement
  }

  const tempDiff = Math.abs(currentWeather.temperature - previousWeather.temperature);
  const windDiff = currentWeather.windSpeed - previousWeather.windSpeed;
  const rainDiff = currentWeather.rainChance - previousWeather.rainChance;

  // Detect sudden temperature drop
  if (tempDiff > 5) {
    return {
      severity: tempDiff > 10 ? 'HIGH' : 'MEDIUM',
      title: 'Mudança de temperatura detectada',
      description: `Temperatura caiu ${tempDiff.toFixed(1)}°C`,
      suggestedAction: 'Ajuste roupas e mantenha-se hidratado',
      timestamp: new Date().toISOString(),
    };
  }

  // Detect increased rain risk
  if (rainDiff > 30) {
    return {
      severity: currentWeather.rainChance > 70 ? 'HIGH' : 'MEDIUM',
      title: 'Risco de chuva aumentou',
      description: `Chance de chuva: ${currentWeather.rainChance}%`,
      suggestedAction: 'Procure abrigo ou leve um guarda-chuva',
      timestamp: new Date().toISOString(),
    };
  }

  // Detect strong wind
  if (windDiff > 10 && currentWeather.windSpeed > 25) {
    return {
      severity: currentWeather.windSpeed > 40 ? 'HIGH' : 'MEDIUM',
      title: 'Vento forte detectado',
      description: `Velocidade do vento: ${currentWeather.windSpeed.toFixed(1)} km/h`,
      suggestedAction: 'Tenha cuidado com objetos soltos',
      timestamp: new Date().toISOString(),
    };
  }

  // Detect high UV index
  if (currentWeather.uvIndex >= 8) {
    return {
      severity: 'HIGH',
      title: 'Índice UV muito alto',
      description: `Índice UV: ${currentWeather.uvIndex}`,
      suggestedAction: 'Use protetor solar forte e busque sombra',
      timestamp: new Date().toISOString(),
    };
  }

  // Detect severe weather conditions
  if (currentWeather.condition === 'stormy' || currentWeather.condition === 'rainy') {
    if (!previousWeather || previousWeather.condition !== 'stormy' && previousWeather.condition !== 'rainy') {
      return {
        severity: currentWeather.condition === 'stormy' ? 'HIGH' : 'MEDIUM',
        title:
          currentWeather.condition === 'stormy' ? 'Tempestade se aproximando' : 'Chuva detectada',
        description: `Condição: ${currentWeather.condition}`,
        suggestedAction:
          currentWeather.condition === 'stormy'
            ? 'Procure abrigo seguro imediatamente'
            : 'Tenha cuidado ao caminhar',
        timestamp: new Date().toISOString(),
      };
    }
  }

  return null;
}

export function assessActivitySuitability(weather, activityType) {
  // Score 0-1 how suitable the activity is given weather conditions
  let score = 1.0;

  // Outdoor activities
  if (activityType === 'outdoor') {
    if (weather.condition === 'rainy') score -= 0.6;
    if (weather.condition === 'stormy') score -= 0.95;
    if (weather.uvIndex >= 8) score -= 0.2;
    if (weather.temperature < 10 || weather.temperature > 35) score -= 0.1;
    if (weather.windSpeed > 30) score -= 0.15;
  }

  // Indoor activities
  if (activityType === 'indoor') {
    // Most indoor activities are good regardless of weather
    score = 0.95;
  }

  // Beach activities
  if (activityType === 'beach') {
    if (weather.condition === 'rainy' || weather.condition === 'stormy') score -= 0.8;
    if (weather.uvIndex >= 8) score -= 0.1;
    if (weather.windSpeed > 25) score -= 0.2;
  }

  return Math.max(0, Math.min(1, score));
}
