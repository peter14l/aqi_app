import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../domain/location_model.dart';
import '../../../constants/api_config.dart';

/// Service for location search using Open-Meteo Geocoding API
class LocationService {
  final http.Client _client;

  LocationService({http.Client? client}) : _client = client ?? http.Client();

  /// Search for locations by name
  /// Returns list of matching locations worldwide
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        '${ApiConfig.openMeteoGeocodingUrl}/search?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results == null || results.isEmpty) {
          return [];
        }

        return results.map((result) {
          return LocationModel(
            name: result['name'] as String,
            latitude: (result['latitude'] as num).toDouble(),
            longitude: (result['longitude'] as num).toDouble(),
            country: result['country'] as String?,
            admin1: result['admin1'] as String?,
          );
        }).toList();
      } else {
        throw Exception('Failed to search locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  /// Get current device location
  Future<LocationModel> getCurrentLocation() async {
    try {
      print('[LocationService] Starting location detection...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('[LocationService] Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        print(
          '[LocationService] Location services are disabled, using fallback',
        );
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('[LocationService] Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('[LocationService] Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          print('[LocationService] Location permissions denied by user');
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[LocationService] Location permissions permanently denied');
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with timeout for web/desktop
      print('[LocationService] Getting current position...');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Add timeout for web/desktop
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print(
            '[LocationService] Position request timed out (common on web/desktop)',
          );
          throw Exception('Location request timed out');
        },
      );

      print(
        '[LocationService] Position obtained: ${position.latitude}, ${position.longitude}',
      );

      // Try to get address from coordinates
      // This may fail on web/desktop, so we'll use a fallback
      try {
        print(
          '[LocationService] Attempting to get place name from coordinates...',
        );
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final locationName =
              place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})';

          print('[LocationService] Location name resolved: $locationName');

          return LocationModel(
            name: locationName,
            latitude: position.latitude,
            longitude: position.longitude,
            country: place.country,
            admin1: place.administrativeArea,
          );
        }
      } catch (geocodingError) {
        print(
          '[LocationService] Geocoding failed (common on web/desktop): $geocodingError',
        );
        // Fall through to use coordinates as name
      }

      // Fallback: use coordinates as the location name
      print('[LocationService] Using coordinates as location name');
      return LocationModel(
        name:
            'Location (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})',
        latitude: position.latitude,
        longitude: position.longitude,
        country: null,
        admin1: null,
      );
    } catch (e) {
      print('[LocationService] Error getting location: $e');
      print('[LocationService] Falling back to default location (Kraków)');

      // Fallback to default location if there's an error
      return const LocationModel(
        name: 'Kraków',
        latitude: 50.0647,
        longitude: 19.9450,
        country: 'Poland',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
