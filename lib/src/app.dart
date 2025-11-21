import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';
import 'constants/app_theme.dart';
import 'features/theme/theme_provider.dart' show AppThemeMode, themeProvider;

class AqiApp extends ConsumerWidget {
  const AqiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'AQI Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode == AppThemeMode.system
          ? ThemeMode.system
          : themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      routerConfig: goRouter,
    );
  }
}
