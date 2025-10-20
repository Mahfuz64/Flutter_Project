import 'package:flutter/material.dart';

class WeatherUtils {
  static String convertTemp(double kelvin, bool isCelsius) {
    if (isCelsius) {
      return (kelvin - 273.15).toStringAsFixed(1);
    } else {
      return ((kelvin - 273.15) * 9 / 5 + 32).toStringAsFixed(1);
    }
  }

  static String getTempUnit(bool isCelsius) {
    return isCelsius ? '°C' : '°F';
  }

  static IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  static Color getBackgroundColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orange.shade100;
      case 'clouds':
        return Colors.grey.shade300;
      case 'rain':
      case 'drizzle':
        return Colors.blue.shade200;
      case 'thunderstorm':
        return Colors.deepPurple.shade200;
      case 'snow':
        return Colors.lightBlue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}