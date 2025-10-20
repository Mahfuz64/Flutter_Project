import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesService {
  static const String _lastCityKey = 'lastCity';
  static const String _isCelsiusKey = 'isCelsius';
  static const String _favoritesKey = 'favorites';
  static const String _cachedWeatherKey = 'cachedWeather';

  Future<String> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey) ?? 'London';
  }

  Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, city);
  }

  Future<bool> getIsCelsius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isCelsiusKey) ?? true;
  }

  Future<void> saveIsCelsius(bool isCelsius) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isCelsiusKey, isCelsius);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<Map<String, dynamic>?> getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cachedWeatherKey);
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }
    return null;
  }

  Future<void> saveCachedWeather(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedWeatherKey, jsonEncode(data));
  }
}
