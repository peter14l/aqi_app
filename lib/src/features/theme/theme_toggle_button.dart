import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      tooltip: isDarkMode 
          ? 'Switch to Light Mode' 
          : 'Switch to Dark Mode',
      onPressed: () {
        themeNotifier.setTheme(
          isDarkMode ? AppThemeMode.light : AppThemeMode.dark,
        );
      },
    );
  }
}
