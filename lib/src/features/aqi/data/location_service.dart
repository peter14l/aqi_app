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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationModel(
          name: '${place.locality ?? 'Unknown Location'}',
          latitude: position.latitude,
          longitude: position.longitude,
          country: place.country,
          admin1: place.administrativeArea,
        );
      } else {
        throw Exception('Could not determine location name');
      }
    } catch (e) {
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
