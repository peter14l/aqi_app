import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/location_model.dart';
import 'location_service.dart';

/// Location notifier for managing state in Riverpod 3.0
class LocationNotifier extends Notifier<LocationState?> {
  final LocationService _locationService = LocationService();
  bool _initialized = false;

  @override
  LocationState? build() {
    if (!_initialized) {
      _initialized = true;
      _initializeLocation();
    }
    return null; // Will be set asynchronously
  }

  Future<void> _initializeLocation() async {
    try {
      print('[LocationNotifier] Initializing location...');

      // First try to load saved location
      final savedLocation = await _loadSavedLocation();
      if (savedLocation != null) {
        print(
          '[LocationNotifier] Loaded saved location: ${savedLocation.name}',
        );
        state = savedLocation;
      }

      // Then try to get current location
      print('[LocationNotifier] Attempting to get current location...');
      final currentLocation = await _locationService.getCurrentLocation();
      print(
        '[LocationNotifier] Current location obtained: ${currentLocation.name} (${currentLocation.latitude}, ${currentLocation.longitude})',
      );

      state = LocationState(
        name: currentLocation.name,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
        country: currentLocation.country,
      );

      print('[LocationNotifier] State updated with current location');

      // Save the detected location
      await _saveLocation(state!);
      print('[LocationNotifier] Location saved to preferences');
    } catch (e) {
      print('[LocationNotifier] Error initializing location: $e');

      // If both saved and current location fail, use default
      state ??= const LocationState(
        name: 'Kraków',
        latitude: 50.0647,
        longitude: 19.9450,
        country: 'Poland',
      );

      print('[LocationNotifier] Using default location: ${state?.name}');
    }
  }

  Future<LocationState?> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_locationKey);
      if (locationJson != null) {
        return LocationState.fromJson(
          json.decode(locationJson) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // Ignore errors and return null
    }
    return null;
  }

  Future<void> _saveLocation(LocationState location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, json.encode(location.toJson()));
    } catch (e) {
      // Ignore errors
    }
  }

  void setLocation(LocationState location) async {
    state = location;
    await _saveLocation(location);
  }
}

/// Provider for location state
final locationProvider = NotifierProvider<LocationNotifier, LocationState?>(
  LocationNotifier.new,
);

const String _locationKey = 'selected_location';

/// Location service provider
class LocationStateService {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  /// Load saved location from shared preferences
  Future<LocationState?> loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationJson = prefs.getString(_locationKey);

      if (locationJson != null) {
        return LocationState.fromJson(
          json.decode(locationJson) as Map<String, dynamic>,
        );
      }
      return const LocationState(
        name: 'Kraków',
        latitude: 50.0647,
        longitude: 19.9450,
        country: 'Poland',
      );
    } catch (e) {
      return const LocationState(
        name: 'Kraków',
        latitude: 50.0647,
        longitude: 19.9450,
        country: 'Poland',
      );
    }
  }

  /// Save location to shared preferences
  Future<void> saveLocation(LocationState location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, json.encode(location.toJson()));
    } catch (e) {
      // Silently fail
    }
  }

  /// Add location to recent searches
  Future<void> addToRecentSearches(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = prefs.getString(_recentSearchesKey);

      List<Map<String, dynamic>> recent = [];
      if (recentJson != null) {
        recent =
            (json.decode(recentJson) as List)
                .cast<Map<String, dynamic>>()
                .toList();
      }

      // Remove if already exists
      recent.removeWhere(
        (item) =>
            item['name'] == location.name &&
            item['country'] == location.country,
      );

      // Add to beginning
      recent.insert(0, {
        'name': location.name,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'country': location.country,
        'admin1': location.admin1,
      });

      // Keep only max recent searches
      if (recent.length > _maxRecentSearches) {
        recent = recent.sublist(0, _maxRecentSearches);
      }

      await prefs.setString(_recentSearchesKey, json.encode(recent));
    } catch (e) {
      // Silently fail for recent searches
    }
  }

  /// Get recent searches
  Future<List<LocationModel>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentJson = prefs.getString(_recentSearchesKey);

      if (recentJson == null) return [];

      final recent =
          (json.decode(recentJson) as List)
              .cast<Map<String, dynamic>>()
              .toList();

      return recent.map((item) {
        return LocationModel(
          name: item['name'] as String,
          latitude: (item['latitude'] as num).toDouble(),
          longitude: (item['longitude'] as num).toDouble(),
          country: item['country'] as String?,
          admin1: item['admin1'] as String?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

/// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Provider for location state service
final locationStateServiceProvider = Provider<LocationStateService>((ref) {
  return LocationStateService();
});
