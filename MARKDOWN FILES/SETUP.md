# Multi-Agent AQI System - Setup Guide

## Overview

This Flutter application implements a comprehensive multi-agent AI system for air quality monitoring and personalized health recommendations. The system uses 8 specialized AI agents coordinated by an orchestrator to provide real-time AQI analysis, predictions, and actionable advice.

## Architecture

### Agents
1. **Data Fetch Agent** - Retrieves real-time and historical AQI/weather data
2. **Analysis Agent** - Interprets data using Google Gemini LLM
3. **Advisory Agent** - Generates personalized recommendations
4. **Prediction Agent** - Forecasts future AQI levels
5. **Simulation Agent** - Runs "what-if" scenarios
6. **Route Exposure Agent** - Calculates PM exposure on routes
7. **Memory Agent** - Manages user preferences and history
8. **Orchestrator Agent** - Coordinates all agents

### Free APIs Used
- **Google Gemini** (gemini-1.5-flash) - LLM for analysis and recommendations
- **WAQI** - Real-time AQI data
- **Open-Meteo** - Weather data and forecasts

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio

### 2. Get API Keys

#### Google Gemini API Key (Required)
1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the API key

#### WAQI API Token (Required)
1. Visit [WAQI Data Platform](https://aqicn.org/data-platform/token/)
2. Request a free API token
3. Check your email for the token

### 3. Configure Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your API keys:
   ```
   WAQI_API_TOKEN=your_actual_waqi_token_here
   GEMINI_API_KEY=your_actual_gemini_key_here
   ```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Generate Code

The app uses code generation for Hive (local storage). Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 6. Run the App

#### Web
```bash
flutter run -d chrome
```

#### Mobile (Android)
```bash
flutter run -d <device-id>
```

#### Desktop (Windows)
```bash
flutter run -d windows
```

#### Desktop (macOS)
```bash
flutter run -d macos
```

## Features

### 1. Real-Time AQI Monitoring
- Current AQI, PM2.5, and PM10 levels
- Weather conditions
- AI-powered analysis of air quality

### 2. AI Insights
- LLM-generated explanations of current conditions
- Health impact assessments
- Contributing factor identification

### 3. Personalized Recommendations
- Activity-based advice (exercise, commute, etc.)
- Risk level calculations based on user profile
- Actionable items with priority levels

### 4. Predictions
- 24-hour AQI forecasts
- Confidence scores
- Time-of-day adjustments for rush hours

### 5. Simulations
- "What-if" scenario analysis
- Traffic impact simulations
- Weather effect projections

### 6. Conversational Interface
- Natural language queries
- Chat history
- Contextual responses

### 7. Memory & Personalization
- User profile storage (age, health conditions, routes)
- Query history
- Habit tracking

## Usage

### Home Screen
- View current AQI and weather
- See AI-generated insights
- Get personalized recommendations
- Access 7-day forecast

### Chat Screen
- Ask questions about air quality
- Get predictions ("What will AQI be tomorrow?")
- Request recommendations ("Should I go for a run?")
- Run simulations ("What if traffic increases by 50%?")

### Habits Screen
- Track daily routines
- Record exposure patterns
- View historical data

### Prediction Screen
- View detailed forecasts
- Analyze trends
- Plan activities

## Troubleshooting

### Build Errors
If you encounter build errors:
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Regenerate code: `dart run build_runner build --delete-conflicting-outputs`

### API Errors
- **"WAQI_API_TOKEN not found"**: Check your `.env` file exists and has the correct token
- **"GEMINI_API_KEY not found"**: Ensure you've added your Gemini API key to `.env`
- **Rate limiting**: Free tier APIs have rate limits. Wait a few minutes and try again.

### LLM Errors
- If Gemini API fails, the app will fall back to rule-based recommendations
- Check your API key is valid and has quota remaining

## Development

### Project Structure
```
lib/
├── src/
│   ├── core/
│   │   ├── agents/          # All agent implementations
│   │   ├── services/        # LLM service, logging
│   │   └── providers/       # Riverpod providers
│   ├── features/
│   │   ├── aqi/            # AQI display and widgets
│   │   ├── chat/           # Conversational interface
│   │   ├── habits/         # Habit tracking
│   │   ├── weather/        # Weather widgets
│   │   └── user/           # User profile
│   ├── constants/          # Colors, text styles
│   └── routing/            # Navigation
└── main.dart
```

### Adding New Agents
1. Create a new file in `lib/src/core/agents/`
2. Extend `AgentBase`
3. Implement `execute()` and `getTools()`
4. Add provider in `lib/src/core/providers/agent_providers.dart`
5. Update orchestrator to include new agent

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/core/agents/data_fetch_agent_test.dart
```

## License

MIT

## Credits

Built with:
- Flutter & Dart
- Google Gemini AI
- WAQI (World Air Quality Index)
- Open-Meteo
- Riverpod for state management
- Hive for local storage
