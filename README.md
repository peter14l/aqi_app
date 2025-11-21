# AQI App

A cross-platform Air Quality Index (AQI) monitoring application built with Flutter. This app provides hyper-local AQI readings, weather information, and personalized habit tracking to reduce exposure to harmful particulates.

## Features

-   **Real-time AQI Monitoring**: View current AQI, PM2.5, and PM10 levels.
-   **Weather Details**: Temperature, Humidity, Pressure, and Wind Speed.
-   **Habits & Exposure Tracking**: Track daily habits and calculate estimated exposure to particulates.
-   **Weekly Forecast**: 7-day AQI prediction.
-   **Cross-Platform**: Optimized for Mobile (iOS/Android) and Desktop/Web.
-   **Dynamic Theming**: Visual feedback based on AQI levels (Green/Good, Orange/Bad).

## Getting Started

### Prerequisites

-   Flutter SDK (Latest Stable)
-   Dart SDK

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/aqi_app.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

## Project Structure

-   `lib/src/features`: Feature-based architecture (AQI, Habits).
-   `lib/src/core`: Core utilities and shared widgets.
-   `lib/src/constants`: App-wide constants (Colors, TextStyles).
-   `lib/src/routing`: Navigation configuration (GoRouter).

## Design

The app follows a modern, clean design with a focus on readability and visual feedback.
-   **Good AQI**: Green theme with soft accents.
-   **Bad AQI**: Orange/Red theme to alert the user.

## License

MIT
