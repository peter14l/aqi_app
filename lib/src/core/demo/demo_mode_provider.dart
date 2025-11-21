import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for demo mode state
final demoModeProvider = StateNotifierProvider<DemoModeNotifier, bool>((ref) {
  return DemoModeNotifier();
});

class DemoModeNotifier extends StateNotifier<bool> {
  static const String _key = 'demo_mode';

  DemoModeNotifier() : super(false) {
    _loadDemoMode();
  }

  Future<void> _loadDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> toggleDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool(_key, state);
  }

  Future<void> setDemoMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    state = enabled;
    await prefs.setBool(_key, state);
  }
}
