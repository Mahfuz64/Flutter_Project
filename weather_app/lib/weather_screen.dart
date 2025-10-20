import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widgets/aditional_info.dart';
import 'package:geolocator/geolocator.dart';


import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/services/location_service.dart';
 import 'package:weather_app/services/preferences_service.dart';
import 'package:weather_app/utils/weather_utils.dart';

class weather_screen extends StatefulWidget {
  const weather_screen({super.key});

  @override
  State<weather_screen> createState() => _weather_screenState();
}

class _weather_screenState extends State<weather_screen> {
  late WeatherService _weatherService;
  late LocationService _locationService;
  late PreferencesService _preferencesService;

  String cityname = "London";
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingLocation = false;
  bool isCelsius = true;
  List<String> favoriteCities = [];
  Map<String, dynamic>? cachedWeatherData;
  
  // Add a key to control when to fetch new data
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherService();
    _locationService = LocationService();
    _preferencesService = PreferencesService();
    _loadPreferences();
    _loadCachedData();
  }

  Future<void> _loadPreferences() async {
    cityname = await _preferencesService.getLastCity();
    isCelsius = await _preferencesService.getIsCelsius();
    favoriteCities = await _preferencesService.getFavorites();
    setState(() {});
  }

  Future<void> _loadCachedData() async {
    cachedWeatherData = await _preferencesService.getCachedWeather();
    setState(() {});
  }

  Future<void> _savePreferences() async {
    await _preferencesService.saveLastCity(cityname);
    await _preferencesService.saveIsCelsius(isCelsius);
    await _preferencesService.saveFavorites(favoriteCities);
  }

  void _toggleTemperatureUnit() {
    setState(() {
      isCelsius = !isCelsius;
    });
    _savePreferences();
  }

  void _toggleFavorite() {
    setState(() {
      if (favoriteCities.contains(cityname)) {
        favoriteCities.remove(cityname);
        _showSnackBar('$cityname removed from favorites', Colors.orange);
      } else {
        favoriteCities.add(cityname);
        _showSnackBar('$cityname added to favorites', Colors.green);
      }
    });
    _savePreferences();
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Favorite Cities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            if (favoriteCities.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No favorite cities yet'),
                ),
              )
            else
              ...favoriteCities.map((city) => ListTile(
                    leading: Icon(Icons.location_city, color: Colors.blue),
                    title: Text(city),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove from favorites',
                      onPressed: () {
                        setState(() {
                          favoriteCities.remove(city);
                          _savePreferences();
                        });
                        Navigator.pop(context);
                        _showSnackBar('$city removed', Colors.orange);
                      },
                    ),
                    onTap: () {
                      setState(() {
                        cityname = city;
                        _savePreferences();
                      });
                      Navigator.pop(context);
                    },
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    final hasPermission = await _locationService.handleLocationPermission();
    if (!hasPermission) {
      setState(() {
        isLoadingLocation = false;
      });
      _showSnackBar(
        'Location permission denied. Enable in settings.',
        Colors.red,
      );
      return;
    }

    try {
      String newCity = await _locationService.getCurrentCity();
      setState(() {
        cityname = newCity;
        isLoadingLocation = false;
        _refreshKey++; // Trigger refresh only when city changes
      });
      await _savePreferences();
      _showSnackBar('Location updated to $cityname', Colors.green);
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });
      _showSnackBar(e.toString(), Colors.red);
    }
  }

  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      final weatherData = await _weatherService.getWeatherData(cityname);
      await _preferencesService.saveCachedWeather(weatherData);
      await _savePreferences();
      return weatherData;
    } catch (e) {
      if (cachedWeatherData != null) {
        _showSnackBar('Showing cached data. $e', Colors.orange);
        return cachedWeatherData!;
      }
      throw e.toString();
    }
  }

  void _searchCity() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        cityname = _searchController.text.trim();
        _refreshKey++; // Trigger refresh when searching new city
      });
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text('Search City'),
          ],
        ),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter city name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.location_city),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) {
            Navigator.pop(context);
            _searchCity();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchCity();
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: _toggleTemperatureUnit,
            icon: Icon(isCelsius ? Icons.thermostat : Icons.thermostat_outlined),
            tooltip: 'Switch to ${isCelsius ? "Fahrenheit" : "Celsius"}',
          ),
          IconButton(
            onPressed: isLoadingLocation ? null : _getCurrentLocation,
            icon: isLoadingLocation
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.my_location),
            tooltip: 'Use Current Location',
          ),
          IconButton(
            onPressed: _showSearchDialog,
            icon: Icon(Icons.search),
            tooltip: 'Search City',
          ),
          PopupMenuButton(
            tooltip: 'More Options',
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Favorite Cities'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, _showFavorites);
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Refresh Weather'),
                  ],
                ),
                onTap: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16),
                  Text('Loading weather data...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!["current"];
          final forecast = snapshot.data!["forecast"];

          final temperature = double.parse(data['main']['temp'].toString());
          final status = data['weather'][0]['main'];
          final description = data['weather'][0]['description'];
          final wind = data['wind']['speed'];
          final humidity = data['main']['humidity'];
          final pressure = data['main']['pressure'];
          final feelsLike = double.parse(data['main']['feels_like'].toString());
          final visibility = (data['visibility'] / 1000).toStringAsFixed(1);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City name with favorite button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.blue, size: 20),
                        SizedBox(width: 4),
                        Text(
                          cityname,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            favoriteCities.contains(cityname)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          tooltip: favoriteCities.contains(cityname)
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Main weather card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            WeatherUtils.getBackgroundColor(status),
                            WeatherUtils.getBackgroundColor(status).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Card(
                        elevation: 4,
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "${WeatherUtils.convertTemp(temperature, isCelsius)} ${WeatherUtils.getTempUnit(isCelsius)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 48,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(WeatherUtils.getWeatherIcon(status), size: 64),
                              SizedBox(height: 8),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Feels like ${WeatherUtils.convertTemp(feelsLike, isCelsius)}${WeatherUtils.getTempUnit(isCelsius)}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Hourly Forecast Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hourly Forecast",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Icon(Icons.access_time, size: 20),
                      ],
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final item = forecast['list'][index];
                          final time = DateTime.parse(item['dt_txt']);
                          final temp = double.parse(item['main']['temp'].toString());
                          final weathersky = item['weather'][0]['main'];

                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat.Hm().format(time),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Icon(
                                      WeatherUtils.getWeatherIcon(weathersky),
                                      size: 28,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "${WeatherUtils.convertTemp(temp, isCelsius)}°",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Additional Information Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Icon(Icons.info_outline, size: 20),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Grid of weather details
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildDetailCard(
                          Icons.water_drop,
                          "Humidity",
                          "$humidity%",
                          Colors.blue,
                        ),
                        _buildDetailCard(
                          Icons.air,
                          "Wind",
                          "${wind.toStringAsFixed(1)} m/s",
                          Colors.teal,
                        ),
                        _buildDetailCard(
                          Icons.compress,
                          "Pressure",
                          "$pressure hPa",
                          Colors.orange,
                        ),
                        _buildDetailCard(
                          Icons.visibility,
                          "Visibility",
                          "$visibility km",
                          Colors.purple,
                        ),
                        _buildDetailCard(
                          Icons.device_thermostat,
                          "Feels Like",
                          "${WeatherUtils.convertTemp(feelsLike, isCelsius)}°",
                          Colors.red,
                        ),
                        _buildDetailCard(
                          Icons.cloud,
                          "Cloudiness",
                          "${data['clouds']['all']}%",
                          Colors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Last updated time
                    Center(
                      child: Text(
                        "Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}