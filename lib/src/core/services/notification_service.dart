import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      _logger.i('Notification service initialized');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize notifications',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.d('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to relevant screen
  }

  /// Show an AQI increase alert notification
  Future<void> showAqiIncreaseAlert({
    required int previousAqi,
    required int currentAqi,
    required String previousCategory,
    required String currentCategory,
    required String location,
  }) async {
    if (!_initialized) await initialize();

    try {
      final difference = currentAqi - previousAqi;
      final androidDetails = AndroidNotificationDetails(
        'aqi_changes',
        'AQI Changes',
        channelDescription: 'Notifications when air quality changes',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        color: _getNotificationColor(currentAqi),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        'aqi_increase'.hashCode,
        '⚠️ Air Quality Worsened in $location',
        'AQI increased from $previousAqi ($previousCategory) to $currentAqi ($currentCategory). Consider limiting outdoor activities.',
        details,
        payload: 'aqi_change',
      );

      _logger.i('AQI increase notification shown: $previousAqi → $currentAqi');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to show AQI increase notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show an AQI decrease alert notification
  Future<void> showAqiDecreaseAlert({
    required int previousAqi,
    required int currentAqi,
    required String previousCategory,
    required String currentCategory,
    required String location,
  }) async {
    if (!_initialized) await initialize();

    try {
      final difference = previousAqi - currentAqi;
      final androidDetails = AndroidNotificationDetails(
        'aqi_changes',
        'AQI Changes',
        channelDescription: 'Notifications when air quality changes',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: true,
        color: _getNotificationColor(currentAqi),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        'aqi_decrease'.hashCode,
        '✅ Air Quality Improved in $location',
        'AQI decreased from $previousAqi ($previousCategory) to $currentAqi ($currentCategory). Great time to go outside!',
        details,
        payload: 'aqi_change',
      );

      _logger.i('AQI decrease notification shown: $previousAqi → $currentAqi');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to show AQI decrease notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show an AQI alert notification
  Future<void> showAqiAlert({
    required int aqi,
    required String status,
    required String message,
  }) async {
    if (!_initialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'aqi_alerts',
        'AQI Alerts',
        channelDescription: 'Notifications for air quality alerts',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        aqi.hashCode, // Use AQI as notification ID
        'Air Quality Alert: $status',
        message,
        details,
        payload: 'aqi_alert_$aqi',
      );

      _logger.i('AQI alert notification shown: $aqi - $status');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to show notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show a recommendation notification
  Future<void> showRecommendation({
    required String title,
    required String message,
  }) async {
    if (!_initialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'recommendations',
        'Recommendations',
        channelDescription: 'Personalized air quality recommendations',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        message,
        details,
        payload: 'recommendation',
      );

      _logger.i('Recommendation notification shown');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to show recommendation',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show a route-based alert notification
  Future<void> showRouteAlert({
    required String routeName,
    required String status,
    required String message,
  }) async {
    if (!_initialized) await initialize();

    try {
      const androidDetails = AndroidNotificationDetails(
        'route_alerts',
        'Route Alerts',
        channelDescription: 'Alerts for commute route air quality',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        'Route Alert: $routeName',
        '$status: $message',
        details,
        payload: 'route_alert',
      );

      _logger.i('Route alert notification shown for $routeName');
    } catch (e, stackTrace) {
      _logger.e('Failed to show route alert', error: e, stackTrace: stackTrace);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    _logger.i('All notifications cancelled');
  }

  /// Get notification color based on AQI value
  Color _getNotificationColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF00E400); // Good - Green
    if (aqi <= 100) return const Color(0xFFFFFF00); // Moderate - Yellow
    if (aqi <= 150)
      return const Color(0xFFFF7E00); // Unhealthy for Sensitive - Orange
    if (aqi <= 200) return const Color(0xFFFF0000); // Unhealthy - Red
    if (aqi <= 300) return const Color(0xFF8F3F97); // Very Unhealthy - Purple
    return const Color(0xFF7E0023); // Hazardous - Maroon
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return result ?? false;
    } catch (e) {
      _logger.e('Failed to request permissions', error: e);
      return false;
    }
  }
}
