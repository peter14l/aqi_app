import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

/// Service for interacting with Google Gemini LLM
class LlmService {
  final GenerativeModel _model;
  final Logger _logger = Logger();

  LlmService._({required GenerativeModel model}) : _model = model;

  /// Factory constructor to create LlmService with API key from environment
  static Future<LlmService> create() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );

    return LlmService._(model: model);
  }

  /// Generate a response from the LLM
  Future<String> generateResponse(String prompt) async {
    try {
      _logger.i('Sending prompt to Gemini: ${prompt.substring(0, 100)}...');

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      _logger.i(
        'Received response from Gemini: ${response.text!.substring(0, 100)}...',
      );
      return response.text!;
    } catch (e, stackTrace) {
      _logger.e(
        'Error generating LLM response',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Generate analysis of AQI data
  Future<String> analyzeAqiData({
    required int aqi,
    required double pm25,
    required double pm10,
    required String location,
    required Map<String, dynamic> weatherData,
  }) async {
    final prompt = '''
You are an air quality expert analyzing environmental data for $location.

Current Data:
- AQI: $aqi
- PM2.5: $pm25 µg/m³
- PM10: $pm10 µg/m³
- Temperature: ${weatherData['temp']}°C
- Humidity: ${weatherData['humidity']}%
- Weather: ${weatherData['condition']}

Provide a concise analysis (2-3 sentences) explaining:
1. What the current AQI level means for health
2. What environmental factors might be contributing to this AQI
3. Any immediate concerns or positive notes

Keep your response factual and helpful.
''';

    return await generateResponse(prompt);
  }

  /// Generate personalized recommendations
  Future<List<String>> generateRecommendations({
    required int aqi,
    required String userActivity,
    required Map<String, dynamic> userProfile,
  }) async {
    final prompt = '''
You are a health advisor providing air quality recommendations.

Current AQI: $aqi
User Activity: $userActivity
User Profile: ${userProfile.toString()}

Provide 3-5 specific, actionable recommendations for this user given the current air quality.
Format each recommendation as a separate line starting with a dash (-).
Keep recommendations practical and health-focused.
''';

    final response = await generateResponse(prompt);

    // Parse recommendations from response
    return response
        .split('\n')
        .where((line) => line.trim().startsWith('-'))
        .map((line) => line.trim().substring(1).trim())
        .toList();
  }

  /// Generate simulation results
  Future<String> simulateScenario({
    required String scenario,
    required Map<String, dynamic> currentData,
    required List<Map<String, dynamic>> historicalData,
  }) async {
    final prompt = '''
You are an environmental scientist running a simulation.

Scenario: $scenario

Current Data: ${currentData.toString()}
Historical Patterns: ${historicalData.length} data points available

Based on the scenario and available data, provide:
1. Projected AQI changes
2. Expected health impacts
3. Recommended actions

Keep your response concise and data-driven.
''';

    return await generateResponse(prompt);
  }
}
