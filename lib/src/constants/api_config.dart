/// API configuration for external services
class ApiConfig {
  // AQICN API
  static const String aqicnApiKey =
      '867114a27d5a47b7db3f317c5bf33aaf023519eb'; // Replace with actual key
  static const String aqicnBaseUrl = 'https://api.waqi.info';

  // Open-Meteo API (no key required)
  static const String openMeteoGeocodingUrl =
      'https://geocoding-api.open-meteo.com/v1';
  static const String openMeteoWeatherUrl = 'https://api.open-meteo.com/v1';
}
