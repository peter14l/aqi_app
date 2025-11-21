import 'dart:io';

class Settings {
  // AQICN (WAQI) token (https://aqicn.org/data-platform/token/)
  final String aqicnToken;
  final double requestTimeout;

  Settings({String? aqicnToken, String? requestTimeout})
    : aqicnToken = aqicnToken ?? Platform.environment['WAQI_API_TOKEN'] ?? '',
      requestTimeout =
          double.tryParse(
            requestTimeout ?? Platform.environment['REQUEST_TIMEOUT'] ?? '8.0',
          ) ??
          8.0;
}

// Singleton pattern to cache settings
Settings? _cachedSettings;

Settings getSettings() {
  _cachedSettings ??= Settings();
  return _cachedSettings!;
}
