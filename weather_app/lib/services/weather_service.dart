import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = "ca2c948ae34fe236db3a8c7e72212532";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5";

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/weather?q=$cityName&APPID=$_apiKey"),
      );

      final data = jsonDecode(response.body);
      if (data["cod"] != 200) {
        throw "City not found. Please check the city name and try again.";
      }
      return data;
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('ClientException')) {
        throw "No internet connection. Please check your network.";
      }
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getForecast(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/forecast?q=$cityName&APPID=$_apiKey"),
      );

      final data = jsonDecode(response.body);
      if (data["cod"] != "200") {
        throw "Unable to fetch forecast data";
      }
      return data;
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('ClientException')) {
        throw "No internet connection. Please check your network.";
      }
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getWeatherData(String cityName) async {
    try {
      final current = await getCurrentWeather(cityName);
      final forecast = await getForecast(cityName);

      return {
        "current": current,
        "forecast": forecast,
      };
    } catch (e) {
      rethrow;
    }
  }
}
