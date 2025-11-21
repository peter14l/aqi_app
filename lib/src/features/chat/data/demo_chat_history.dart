import '../domain/chat_message.dart';

/// Demo chat history for impressive demonstrations
class DemoChatHistory {
  static final List<ChatMessage> messages = [
    ChatMessage(
      text: 'What is the current air quality?',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ChatMessage(
      text: '''Current Air Quality Analysis:

AQI: 87 (Moderate)
Location: Cracow, Poland

The current AQI of 87 indicates moderate air quality. High humidity (82%) is trapping pollutants near ground level. PM2.5 levels from vehicle emissions are elevated during rush hour.

Health Impact: Moderate
- Unusually sensitive people should consider reducing prolonged outdoor exertion
- General public: No significant health concerns

Contributing Factors:
• High PM2.5 (25 µg/m³) from traffic emissions
• Low wind speed (2.3 km/h) limiting dispersion
• High humidity (82%) trapping pollutants''',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      agentName: 'AnalysisAgent',
    ),
    ChatMessage(
      text: 'Should I go for a run right now?',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    ChatMessage(
      text:
          '''Based on current AQI (87 - Moderate), here are my recommendations:

🏃 Running Recommendations:
• Postpone outdoor running until evening (predicted AQI: 62)
• If you must run now, choose indoor treadmill
• Consider wearing an N95 mask for outdoor exercise
• Stay well hydrated to help your body filter pollutants

⏰ Best Time Today:
Evening (6-8 PM) when AQI is expected to drop to 62 (Good)

🎯 Alternative Options:
• Indoor gym workout
• Yoga or stretching at home
• Wait 3-4 hours for better air quality''',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      agentName: 'AdvisoryAgent',
    ),
    ChatMessage(
      text: 'What if traffic increases by 50%?',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ChatMessage(
      text: '''Simulation Results: Traffic +50%

📊 Projected Changes:
Current AQI: 87 → Projected AQI: 113 (Unhealthy for Sensitive Groups)

🔬 Analysis:
A 50% increase in traffic would significantly impact air quality:
• PM2.5 would rise from 25 to 38 µg/m³
• PM10 would increase from 45 to 68 µg/m³
• NO2 levels would spike by 40%

⚠️ Health Impact:
• Sensitive groups (children, elderly, respiratory conditions) should avoid outdoor activities
• General public should reduce prolonged outdoor exertion
• Indoor air purifiers recommended

💡 Recommendations:
• Avoid peak traffic hours (7-9 AM, 5-7 PM)
• Use public transportation to reduce emissions
• Consider working from home if possible
• Close windows during rush hour''',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      agentName: 'SimulationAgent',
    ),
    ChatMessage(
      text: 'Predict AQI for tomorrow morning',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    ChatMessage(
      text: '''24-Hour AQI Prediction:

📅 Tomorrow Morning (8 AM):
Predicted AQI: 72 (Moderate)

📈 Trend Analysis:
• Current: 87 (Moderate)
• Tonight: 65 (Good) - Lower traffic, cooler temperatures
• Tomorrow 8 AM: 72 (Moderate) - Morning rush hour begins

🌤️ Weather Factors:
• Temperature: 18°C (favorable for dispersion)
• Wind Speed: 8 km/h (moderate, helps clear pollutants)
• Humidity: 65% (lower than today)
• Precipitation: 20% chance (could improve AQI)

✅ Confidence: 75%

💡 Morning Recommendations:
• Good time for outdoor exercise (before 8 AM)
• Open windows for fresh air (6-7 AM)
• Commute earlier to avoid peak pollution''',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      agentName: 'PredictionAgent',
      confidence: 0.75,
    ),
  ];

  static List<ChatMessage> get demoMessages => messages;
}
