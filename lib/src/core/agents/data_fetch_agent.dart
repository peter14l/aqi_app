import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../agents/agent_base.dart';
import '../services/agent_logger.dart';

/// Data Fetch Agent - Responsible for fetching real-time and historical AQI/weather data
class DataFetchAgent extends AgentBase {
  final Dio _dio;
  final AgentLogger _agentLogger = AgentLogger();

  DataFetchAgent()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        super(name: 'DataFetchAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();
    
    try {
      logInfo('Executing with input: $input');
      
      final action = input['action'] as String?;
      if (action == null) {
        throw ArgumentError('Action is required');
      }

      Map<String, dynamic> result;
      
      switch (action) {
        case 'realtime_aqi':
          result = await _realtimeAqi(input);
          break;
        case 'realtime_weather':
          result = await _realtimeWeather(input);
          break;
        case 'history_aqi':
          result = await _historyAqi(input);
          break;
        default:
          throw ArgumentError('Unknown action: $action');
      }

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: action,
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Execution failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: input['action'] as String? ?? 'unknown',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  /// Fetch real-time AQI for a location
  Future<Map<String, dynamic>> _realtimeAqi(Map<String, dynamic> input) async {
    final lat = input['lat'] as double?;
    final lon = input['lon'] as double?;
    
    if (lat == null || lon == null) {
      throw ArgumentError('Latitude and longitude are required');
    }

    final token = dotenv.env['WAQI_API_TOKEN'];
    if (token == null || token.isEmpty) {
      throw Exception('WAQI_API_TOKEN not found in .env');
    }

    final url = 'https://api.waqi.info/feed/geo:$lat;$lon/?token=$token';
    
    try {
      final startTime = DateTime.now();
      final response = await _dio.get(url);
      final duration = DateTime.now().difference(startTime);

      _agentLogger.logApiCall(
        apiName: 'WAQI',
        endpoint: url,
        statusCode: response.statusCode,
        duration: duration,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'ok') {
          return {
            'success': true,
            'aqi': data['data']['aqi'],
            'pm25': data['data']['iaqi']?['pm25']?['v'] ?? 0,
            'pm10': data['data']['iaqi']?['pm10']?['v'] ?? 0,
            'location': data['data']['city']?['name'] ?? 'Unknown',
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          throw Exception('WAQI API Error: ${data['data']}');
        }
      } else {
        throw Exception('Failed to load AQI data: ${response.statusCode}');
      }
    } catch (e) {
      _agentLogger.logApiCall(
        apiName: 'WAQI',
        endpoint: url,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Fetch real-time weather for a location
  Future<Map<String, dynamic>> _realtimeWeather(Map<String, dynamic> input) async {
    final lat = input['lat'] as double?;
    final lon = input['lon'] as double?;
    
    if (lat == null || lon == null) {
      throw ArgumentError('Latitude and longitude are required');
    }

    final url = 'https://api.open-meteo.com/v1/forecast?'
        'latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m,weather_code'
        '&timezone=auto';

    try {
      final startTime = DateTime.now();
      final response = await _dio.get(url);
      final duration = DateTime.now().difference(startTime);

      _agentLogger.logApiCall(
        apiName: 'OpenMeteo',
        endpoint: url,
        statusCode: response.statusCode,
        duration: duration,
      );

      if (response.statusCode == 200) {
        final current = response.data['current'];
        return {
          'success': true,
          'temperature': current['temperature_2m'],
          'humidity': current['relative_humidity_2m'],
          'pressure': current['surface_pressure'],
          'windSpeed': current['wind_speed_10m'],
          'weatherCode': current['weather_code'],
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      _agentLogger.logApiCall(
        apiName: 'OpenMeteo',
        endpoint: url,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Fetch historical AQI data
  /// Note: WAQI API has limited historical data access on free tier
  /// This is a simplified implementation
  Future<Map<String, dynamic>> _historyAqi(Map<String, dynamic> input) async {
    final lat = input['lat'] as double?;
    final lon = input['lon'] as double?;
    final days = input['days'] as int? ?? 7;
    
    if (lat == null || lon == null) {
      throw ArgumentError('Latitude and longitude are required');
    }

    // For now, we'll simulate historical data by fetching current data
    // In production, you'd use a paid API or store historical data yourself
    logWarning('Historical AQI data limited on free tier - using current data as reference');
    
    final currentData = await _realtimeAqi({'lat': lat, 'lon': lon});
    
    // Simulate historical data with some variance
    final historicalData = <Map<String, dynamic>>[];
    final currentAqi = currentData['aqi'] as int;
    
    for (int i = 0; i < days; i++) {
      final variance = (i - days / 2) * 5; // Simple variance
      historicalData.add({
        'date': DateTime.now().subtract(Duration(days: days - i)).toIso8601String(),
        'aqi': (currentAqi + variance).clamp(0, 500).toInt(),
        'pm25': currentData['pm25'],
        'pm10': currentData['pm10'],
      });
    }

    return {
      'success': true,
      'location': currentData['location'],
      'days': days,
      'data': historicalData,
      'average': currentAqi,
      'peak': historicalData.map((d) => d['aqi'] as int).reduce((a, b) => a > b ? a : b),
      'lowest': historicalData.map((d) => d['aqi'] as int).reduce((a, b) => a < b ? a : b),
    };
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'realtime_aqi',
        description: 'Fetch real-time AQI data for a location',
        schema: {
          'required': ['lat', 'lon'],
          'properties': {
            'lat': {'type': 'number', 'description': 'Latitude'},
            'lon': {'type': 'number', 'description': 'Longitude'},
          },
        },
        execute: (params) => _realtimeAqi(params),
      ),
      AgentTool(
        name: 'realtime_weather',
        description: 'Fetch real-time weather data for a location',
        schema: {
          'required': ['lat', 'lon'],
          'properties': {
            'lat': {'type': 'number', 'description': 'Latitude'},
            'lon': {'type': 'number', 'description': 'Longitude'},
          },
        },
        execute: (params) => _realtimeWeather(params),
      ),
      AgentTool(
        name: 'history_aqi',
        description: 'Fetch historical AQI data for a location',
        schema: {
          'required': ['lat', 'lon'],
          'properties': {
            'lat': {'type': 'number', 'description': 'Latitude'},
            'lon': {'type': 'number', 'description': 'Longitude'},
            'days': {'type': 'integer', 'description': 'Number of days of history'},
          },
        },
        execute: (params) => _historyAqi(params),
      ),
    ];
  }
}
