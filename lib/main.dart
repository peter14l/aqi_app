import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Uncomment when Supabase is ready
import 'src/app.dart';
import 'src/features/purifier/purifier_module.dart';
import 'src/features/purifier/application/providers.dart' as purifier_providers;
import 'src/features/splash/splash_screen.dart';
import 'src/features/achievements/data/achievements_repository.dart';

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
