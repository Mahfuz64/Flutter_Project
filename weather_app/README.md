# ☁️ Weather App

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

## 🛠️ Tech Stack
- **Framework:** Flutter  
- **API:** OpenWeatherMap  
- **Location:** geolocator, geocoding  
- **Persistence:** shared_preferences  
- **Utilities:** intl  
