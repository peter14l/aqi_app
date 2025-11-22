import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../features/aqi/data/aqi_service.dart';
import 'notification_service.dart';

/// Service for monitoring AQI changes and triggering notifications
class AqiMonitorService {
  static final AqiMonitorService _instance = AqiMonitorService._internal();
  factory AqiMonitorService() => _instance;

  AqiMonitorService._internal();

  final Logger _logger = Logger();
  static const String _lastAqiKey = 'last_aqi_value';
  static const String _lastAqiLatKey = 'last_aqi_latitude';
  static const String _lastAqiLonKey = 'last_aqi_longitude';
  static const String _lastAqiCategoryKey = 'last_aqi_category';
  static const String _lastCheckTimeKey = 'last_aqi_check_time';

  // Threshold for significant AQI change (in points)
  static const int changeThreshold = 10;

  // Minimum time between notifications (in minutes) to avoid spam
  static const int minNotificationInterval = 10;

  /// Initialize the monitoring service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAqi = prefs.getInt(_lastAqiKey);

      if (lastAqi != null) {
        _logger.i('AQI Monitor initialized with last AQI: $lastAqi');
      } else {
        _logger.i('AQI Monitor initialized - no previous data');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize AQI monitor',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check for AQI changes at the given location
  Future<void> checkAqiChanges(double latitude, double longitude) async {
    try {
      _logger.i('Checking AQI changes for location: $latitude, $longitude');

      final prefs = await SharedPreferences.getInstance();

      // Check if enough time has passed since last notification
      final lastCheckTime = prefs.getInt(_lastCheckTimeKey);
      if (lastCheckTime != null) {
        final timeSinceLastCheck =
            DateTime.now().millisecondsSinceEpoch - lastCheckTime;
        final minutesSinceLastCheck = timeSinceLastCheck / (1000 * 60);

        if (minutesSinceLastCheck < minNotificationInterval) {
          _logger.d('Skipping notification - too soon since last check');
          return;
        }
      }

      // Fetch current AQI
      final aqiService = AqiService();
      final aqiData = await aqiService.getAqiByCoordinates(latitude, longitude);
      final currentAqi = aqiData['aqi'] as int;
      final cityName = aqiData['city'] as String;

      _logger.i('Current AQI: $currentAqi for $cityName');

      // Get previous AQI data
      final previousAqi = prefs.getInt(_lastAqiKey);
      final previousLat = prefs.getDouble(_lastAqiLatKey);
      final previousLon = prefs.getDouble(_lastAqiLonKey);
      final previousCategory = prefs.getString(_lastAqiCategoryKey);

      // Save current AQI data
      await _saveAqiData(
        prefs,
        currentAqi,
        latitude,
        longitude,
        _getAqiCategory(currentAqi),
      );

      // If no previous data or location changed significantly, just save and return
      if (previousAqi == null ||
          previousLat == null ||
          previousLon == null ||
          _locationChangedSignificantly(
            latitude,
            longitude,
            previousLat,
            previousLon,
          )) {
        _logger.i(
          'No previous data or location changed - establishing baseline',
        );
        return;
      }

      // Check for significant changes
      final currentCategory = _getAqiCategory(currentAqi);
      final aqiDifference = currentAqi - previousAqi;

      if (_isSignificantChange(
        previousAqi,
        currentAqi,
        previousCategory,
        currentCategory,
      )) {
        _logger.i(
          'Significant AQI change detected: $previousAqi → $currentAqi',
        );

        final notificationService = NotificationService();
        await notificationService.initialize();

        if (aqiDifference > 0) {
          // AQI increased (air quality worsened)
          await notificationService.showAqiIncreaseAlert(
            previousAqi: previousAqi,
            currentAqi: currentAqi,
            previousCategory: previousCategory ?? 'Unknown',
            currentCategory: currentCategory,
            location: cityName,
          );
        } else {
          // AQI decreased (air quality improved)
          await notificationService.showAqiDecreaseAlert(
            previousAqi: previousAqi,
            currentAqi: currentAqi,
            previousCategory: previousCategory ?? 'Unknown',
            currentCategory: currentCategory,
            location: cityName,
          );
        }

        // Update last check time
        await prefs.setInt(
          _lastCheckTimeKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        _logger.d('No significant AQI change detected');
      }

      aqiService.dispose();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to check AQI changes',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Save AQI data to shared preferences
  Future<void> _saveAqiData(
    SharedPreferences prefs,
    int aqi,
    double latitude,
    double longitude,
    String category,
  ) async {
    await prefs.setInt(_lastAqiKey, aqi);
    await prefs.setDouble(_lastAqiLatKey, latitude);
    await prefs.setDouble(_lastAqiLonKey, longitude);
    await prefs.setString(_lastAqiCategoryKey, category);
  }

  /// Check if location changed significantly (more than ~1km)
  bool _locationChangedSignificantly(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simple distance check (approximately 0.01 degrees = ~1km)
    final latDiff = (lat1 - lat2).abs();
    final lonDiff = (lon1 - lon2).abs();
    return latDiff > 0.01 || lonDiff > 0.01;
  }

  /// Determine if the AQI change is significant enough to notify
  bool _isSignificantChange(
    int previousAqi,
    int currentAqi,
    String? previousCategory,
    String currentCategory,
  ) {
    // Check if AQI changed by threshold amount
    final aqiDifference = (currentAqi - previousAqi).abs();
    if (aqiDifference >= changeThreshold) {
      return true;
    }

    // Check if category changed
    if (previousCategory != null && previousCategory != currentCategory) {
      return true;
    }

    return false;
  }

  /// Get AQI category from AQI value
  String _getAqiCategory(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  /// Get user-friendly description of AQI change
  String getChangeDescription(int previousAqi, int currentAqi) {
    final difference = currentAqi - previousAqi;
    if (difference > 0) {
      return 'Air quality has worsened by ${difference.abs()} points';
    } else {
      return 'Air quality has improved by ${difference.abs()} points';
    }
  }
}
