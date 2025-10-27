# ☁️ Flutter Weather App

A dynamic and user-friendly **Weather Forecast Application** built with **Flutter**.  
This app integrates the **OpenWeatherMap API** to fetch real-time weather data and uses multiple Flutter services for location, persistence, and utility management.

---

## 🚀 Project Overview
The Flutter Weather App provides accurate, real-time weather updates based on the user's current location or any city they search for.  
It combines modern UI design with essential features like hourly forecasts, city management, and temperature unit customization — all stored locally for a seamless experience.

---

## ✨ Key Features
- **🌤️ Real-time Weather Display:** Shows current temperature, conditions (clear, cloudy, rain, etc.), and location details.  
- **🕐 Hourly Forecast:** Displays a scrollable hourly forecast to help users plan their day.  
- **📍 Location Services:** Automatically detects and updates weather based on the user’s current location using `geolocator` and `geocoding`.  
- **🏙️ City Search:** Search and view weather information for any city worldwide.  
- **💾 Persistent Preferences:** Saves user preferences and last-searched data using `shared_preferences`.  
  - Remembers **last searched city**  
  - Toggle between **Celsius (°C)** and **Fahrenheit (°F)**  
  - Manage **favorite cities** for quick access  
- **🌡️ Detailed Metrics:** Displays additional data such as humidity, wind speed, and pressure.  
- **🖤 Modern UI:** Features a sleek dark mode (`ThemeData.dark`) for a clean, elegant appearance.

---

## 🧩 Technical Components

| Component | Files | Description |
|------------|-------|-------------|
| **User Interface (UI)** | `main.dart`, `weather_screen.dart`, `hourly_forecast.dart`, `aditional_info.dart` | Core UI screens and widgets for weather display and user interactions. |
| **API Integration** | `weather_service.dart` | Handles all requests to the **OpenWeatherMap API** for current weather and forecast data. |
| **Location Handling** | `location_service.dart` | Manages permissions and retrieves current location using `geolocator` and `geocoding`. |
| **Persistence** | `preferences_service.dart` | Uses `shared_preferences` for saving settings, favorites, and last-viewed city. |
| **Utilities** | `weather_utils.dart` | Provides helper functions for temperature conversion and weather condition mapping to icons and colors. |

---

## 🛠️ Tech Stack
- **Framework:** Flutter  
- **API:** OpenWeatherMap  
- **Location:** geolocator, geocoding  
- **Persistence:** shared_preferences  
- **Utilities:** intl  
