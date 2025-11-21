/// Safety validator for AQI values and health recommendations
class SafetyValidator {
  /// Validate AQI value is within acceptable range
  static bool validateAqiValue(dynamic value) {
    if (value is! int) return false;
    return value >= 0 && value <= 500;
  }

  /// Validate PM2.5 value
  static bool validatePm25(dynamic value) {
    if (value is! double && value is! int) return false;
    final numValue = value is int ? value.toDouble() : value as double;
    return numValue >= 0 && numValue <= 1000; // Reasonable upper limit
  }

  /// Validate PM10 value
  static bool validatePm10(dynamic value) {
    if (value is! double && value is! int) return false;
    final numValue = value is int ? value.toDouble() : value as double;
    return numValue >= 0 && numValue <= 2000; // Reasonable upper limit
  }

  /// Validate temperature value
  static bool validateTemperature(dynamic value) {
    if (value is! double && value is! int) return false;
    final numValue = value is int ? value.toDouble() : value as double;
    return numValue >= -50 && numValue <= 60; // Celsius range
  }

  /// Check if health advice is safe (no dangerous recommendations)
  static bool validateHealthAdvice(String advice) {
    final lowerAdvice = advice.toLowerCase();

    // Dangerous phrases that should never appear
    final dangerousPhrases = [
      'ignore symptoms',
      'don\'t worry about',
      'perfectly safe at any level',
      'no need for masks ever',
    ];

    for (final phrase in dangerousPhrases) {
      if (lowerAdvice.contains(phrase)) {
        return false;
      }
    }

    return true;
  }

  /// Validate that recommendations match AQI level
  static bool validateRecommendationsMatchAqi(
    int aqi,
    List<String> recommendations,
  ) {
    final recText = recommendations.join(' ').toLowerCase();

    if (aqi > 150) {
      // Should mention masks or limiting outdoor activity
      return recText.contains('mask') ||
          recText.contains('limit') ||
          recText.contains('avoid') ||
          recText.contains('indoor');
    }

    if (aqi <= 50) {
      // Should NOT recommend avoiding outdoor activity
      return !recText.contains('avoid outdoor') &&
          !recText.contains('stay indoors');
    }

    return true;
  }

  /// Sanitize LLM output to prevent hallucinated AQI values
  static Map<String, dynamic> sanitizeLlmOutput(
    Map<String, dynamic> output,
    Map<String, dynamic> actualData,
  ) {
    final sanitized = Map<String, dynamic>.from(output);

    // If LLM mentions specific AQI values, replace with actual
    if (actualData.containsKey('aqi')) {
      sanitized['actualAqi'] = actualData['aqi'];
    }

    if (actualData.containsKey('pm25')) {
      sanitized['actualPm25'] = actualData['pm25'];
    }

    if (actualData.containsKey('pm10')) {
      sanitized['actualPm10'] = actualData['pm10'];
    }

    return sanitized;
  }

  /// Validate complete agent response
  static Map<String, dynamic> validateAgentResponse(
    Map<String, dynamic> response,
  ) {
    final errors = <String>[];

    // Check for required fields
    if (!response.containsKey('success')) {
      errors.add('Missing success field');
    }

    // Validate AQI if present
    if (response.containsKey('aqi') && !validateAqiValue(response['aqi'])) {
      errors.add('Invalid AQI value: ${response['aqi']}');
    }

    // Validate PM values if present
    if (response.containsKey('pm25') && !validatePm25(response['pm25'])) {
      errors.add('Invalid PM2.5 value: ${response['pm25']}');
    }

    if (response.containsKey('pm10') && !validatePm10(response['pm10'])) {
      errors.add('Invalid PM10 value: ${response['pm10']}');
    }

    // Validate health advice if present
    if (response.containsKey('analysis')) {
      final analysis = response['analysis'];
      if (analysis is String && !validateHealthAdvice(analysis)) {
        errors.add('Potentially unsafe health advice detected');
      }
    }

    return {'valid': errors.isEmpty, 'errors': errors, 'response': response};
  }
}
