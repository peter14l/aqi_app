import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment when Supabase is ready
import 'src/app.dart';
import 'src/features/purifier/purifier_module.dart';
import 'src/features/purifier/application/providers.dart' as purifier_providers;
import 'src/features/splash/splash_screen.dart';
import 'src/features/achievements/data/achievements_repository.dart';
import 'src/core/services/notification_service.dart';
import 'src/core/services/background_scheduler.dart';
import 'src/core/services/aqi_monitor_service.dart';
import 'src/core/widgets/background_permission_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Failed to load .env file: $e");
  }
  // await Supabase.initialize(
  //   url: dotenv.env['SUPABASE_URL'] ?? '',
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  // );

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize PurifierModule
  final purifierModule = await PurifierModule.initialize();

  // Initialize AchievementsRepository
  await AchievementsRepository().init();

  // Initialize notification and background services
  await _initializeNotificationServices();

  // Run the app with overrides
  runApp(
    ProviderScope(
      overrides: [
        purifierModuleProvider.overrideWithValue(purifierModule),
        purifier_providers.purifierRepositoryProvider.overrideWithValue(
          purifierModule.purifierRepository,
        ),
      ],
      child: const SplashWrapper(),
    ),
  );

  // Close Hive when app is closed
  await Hive.close();
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onComplete: () {
            setState(() => _showSplash = false);
          },
        ),
      );
    }
    return const AqiApp();
  }
}

/// Initialize notification and background monitoring services
Future<void> _initializeNotificationServices() async {
  try {
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Request notification permissions
    await notificationService.requestPermissions();

    // Initialize background scheduler
    final backgroundScheduler = BackgroundScheduler();
    await backgroundScheduler.initialize();

    // Initialize AQI monitor service
    final aqiMonitor = AqiMonitorService();
    await aqiMonitor.initialize();

    // Check if user has granted background permission
    final prefs = await SharedPreferences.getInstance();
    final hasAskedPermission =
        prefs.getBool('has_asked_background_permission') ?? false;

    if (!hasAskedPermission) {
      // Mark that we've asked (will show dialog in app)
      await prefs.setBool('has_asked_background_permission', true);
      await prefs.setBool('background_monitoring_enabled', true);
    }

    final monitoringEnabled =
        prefs.getBool('background_monitoring_enabled') ?? false;

    if (monitoringEnabled) {
      // Schedule AQI monitoring every 15 minutes
      await backgroundScheduler.scheduleAqiMonitoring(
        frequency: const Duration(minutes: 15),
      );

      debugPrint('✅ AQI monitoring scheduled (every 15 minutes)');
    }
  } catch (e) {
    debugPrint('⚠️ Failed to initialize notification services: $e');
  }
}
