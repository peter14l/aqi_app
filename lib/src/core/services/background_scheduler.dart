import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'aqi_monitor_service.dart';
import '../agents/memory_agent.dart';
import '../agents/route_exposure_agent.dart';

/// Background task scheduler for periodic AQI checks
class BackgroundScheduler {
  static final BackgroundScheduler _instance = BackgroundScheduler._internal();
  factory BackgroundScheduler() => _instance;

  BackgroundScheduler._internal();

  final Logger _logger = Logger();
  static const String _aqiCheckTask = 'aqi_check_task';
  static const String _aqiMonitorTask = 'aqi_monitor_task';

  /// Initialize background task scheduler
  Future<void> initialize() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      _logger.i('Background scheduler initialized');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize background scheduler',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Schedule periodic AQI checks
  Future<void> scheduleAqiChecks({
    Duration frequency = const Duration(hours: 1),
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        _aqiCheckTask,
        _aqiCheckTask,
        frequency: frequency,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      _logger.i(
        'Scheduled periodic AQI checks every ${frequency.inHours} hours',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to schedule AQI checks',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Schedule periodic AQI monitoring for change detection
  Future<void> scheduleAqiMonitoring({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    try {
      await Workmanager().registerPeriodicTask(
        _aqiMonitorTask,
        _aqiMonitorTask,
        frequency: frequency,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      _logger.i(
        'Scheduled AQI monitoring every ${frequency.inMinutes} minutes',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to schedule AQI monitoring',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel all scheduled tasks
  Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
      _logger.i('Cancelled all background tasks');
    } catch (e) {
      _logger.e('Failed to cancel tasks', error: e);
    }
  }
}

/// Callback dispatcher for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final logger = Logger();

    try {
      logger.i('Background task started: $task');

      if (task == 'aqi_check_task') {
        // Initialize services
        final notificationService = NotificationService();
        await notificationService.initialize();

        // Initialize Agents
        final memoryAgent = MemoryAgent();
        final routeExposureAgent = RouteExposureAgent();

        try {
          // Initialize Memory Agent (loads Hive)
          await memoryAgent.initialize();

          // Fetch User Profile to get routes
          final profileResult = await memoryAgent.execute({
            'action': 'get_profile',
          });
          final profile = profileResult['profile'] as Map<String, dynamic>?;

          if (profile != null) {
            final dailyRoutes =
                (profile['dailyRoutes'] as List?)?.cast<String>() ?? [];

            if (dailyRoutes.isNotEmpty) {
              // For now, we just take the first route name and simulate coordinates
              // In a real app, we'd fetch the actual coordinates for this route name
              // or the route would be stored as coordinates.
              // Assuming 'dailyRoutes' contains names like "Commute to Work"

              // Simulate fetching route coordinates (mock data for now as we don't have a real route service yet)
              final mockRouteCoordinates = [
                {'lat': 50.0647, 'lon': 19.9450}, // Krakow
                {'lat': 50.0614, 'lon': 19.9366}, // Main Square
              ];

              // Simulate fetching AQI data for the route area
              // In production, use DataFetchAgent here
              final mockAqiData = {
                'aqi': 112,
                'pm25': 38.5,
                'pm10': 45.2,
                'durationMinutes': 45,
              };

              // Calculate Exposure
              final exposureResult = await routeExposureAgent.execute({
                'route': mockRouteCoordinates,
                'aqiData': mockAqiData,
              });

              final exposure =
                  exposureResult['exposure'] as Map<String, dynamic>;
              final totalExposure = exposure['totalExposure'] as double;
              final score = exposureResult['score'] as Map<String, dynamic>;
              final rating = score['rating'] as String;

              // Threshold for notification (e.g., if rating is Poor or Very Poor)
              if (rating == 'Poor' ||
                  rating == 'Very Poor' ||
                  totalExposure > 30.0) {
                await notificationService.showRouteAlert(
                  routeName: dailyRoutes.first,
                  status: rating,
                  message:
                      'High exposure detected on your route. ${score['healthImpact']}',
                );
              } else {
                // Optional: Notify good conditions or silent
                logger.i('Route exposure is acceptable: $rating');
              }
            } else {
              logger.i('No daily routes found for user.');
            }
          } else {
            logger.i('No user profile found.');
          }
        } catch (e) {
          logger.e('Error in route check logic', error: e);
        }
      } else if (task == 'aqi_monitor_task') {
        // AQI monitoring task for change detection
        try {
          // Get user's current location from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final locationJson = prefs.getString('selected_location');

          if (locationJson != null) {
            final locationData = Map<String, dynamic>.from(
              jsonDecode(locationJson) as Map,
            );

            final latitude = locationData['latitude'] as double?;
            final longitude = locationData['longitude'] as double?;

            if (latitude != null && longitude != null) {
              // Check for AQI changes
              final aqiMonitor = AqiMonitorService();
              await aqiMonitor.initialize();
              await aqiMonitor.checkAqiChanges(latitude, longitude);

              logger.i(
                'AQI monitoring completed for location: $latitude, $longitude',
              );
            } else {
              logger.w('Location coordinates not found in saved data');
            }
          } else {
            logger.w('No saved location found for AQI monitoring');
          }
        } catch (e, stackTrace) {
          logger.e(
            'Error in AQI monitoring task',
            error: e,
            stackTrace: stackTrace,
          );
        }
      }

      return Future.value(true);
    } catch (e, stackTrace) {
      logger.e('Background task failed', error: e, stackTrace: stackTrace);
      return Future.value(false);
    }
  });
}
