import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting dates

const String apiUrl = 'https://api.openweathermap.org/data/2.5/';
const String apiKey = 'c19f22cae178e39e4a10131dcc393a7a';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _filteredForecastData;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> fetchWeather(String city) async {
    setState(() {
      _isLoading = true; // Start loading
      _currentWeather = null;
      _filteredForecastData = null;
      _errorMessage = null;
    });

    final currentWeatherUrl =
        Uri.parse('${apiUrl}weather?q=$city&appid=$apiKey&units=metric');
    final forecastUrl =
        Uri.parse('${apiUrl}forecast?q=$city&appid=$apiKey&units=metric');

    try {
      final currentWeatherResponse = await http.get(currentWeatherUrl);
      final forecastResponse = await http.get(forecastUrl);

      if (currentWeatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body)['list'];
        final filteredForecast = _filterForecast(forecastData);

        setState(() {
          _currentWeather = json.decode(currentWeatherResponse.body);
          _filteredForecastData = filteredForecast;
        });
      } else {
        setState(() {
          _errorMessage = 'City not found or API error';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data';
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  List<Map<String, dynamic>> _filterForecast(List<dynamic> forecastData) {
    Map<String, Map<String, dynamic>> dailyForecast = {};

    for (var forecast in forecastData) {
      final date = DateTime.parse(forecast['dt_txt']);
      final day = DateFormat('yyyy-MM-dd').format(date);
      final hour = date.hour;

      // Select a single forecast per day (e.g., 12:00 PM or closest).
      if (!dailyForecast.containsKey(day) || (hour == 12)) {
        dailyForecast[day] = forecast;
      }
    }

    // Return the filtered forecasts sorted by date.
    return dailyForecast.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003366), Color(0xFF607D8B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent scaffold
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40), // Top padding for design
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Enter city name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      fetchWeather(_cityController.text);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  shadowColor: Colors.black.withOpacity(0.3),
                  backgroundColor:
                      Colors.transparent, // Ensures no background color
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        fetchWeather(_cityController.text);
                      },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF607D8B),
                        Color(0xFF003366),
                      ], // Gradient colors
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      minHeight: 50,
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Loading...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            'Get Weather',
                            style: TextStyle(fontSize: 21, color: Colors.white),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _errorMessage != null
                  ? Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    )
                  : _currentWeather != null && _filteredForecastData != null
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Current Weather
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF003366),
                                        Color(0xFF607D8B),
                                      ], // Gradient colors
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        8), // Optional, for rounded corners
                                  ),
                                  child: Card(
                                    color: Colors
                                        .transparent, // Ensure the card itself is transparent
                                    elevation: 6,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Current Weather in ${_currentWeather!['name']}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .white), // Text color can be adjusted
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Temperature: ${_currentWeather!['main']['temp']}°C',
                                            style: const TextStyle(
                                                color: Colors
                                                    .white), // Adjust text color
                                          ),
                                          Text(
                                            'Humidity: ${_currentWeather!['main']['humidity']}%',
                                            style: const TextStyle(
                                                color: Colors
                                                    .white), // Adjust text color
                                          ),
                                          Text(
                                            'Wind Speed: ${_currentWeather!['wind']['speed']} m/s',
                                            style: const TextStyle(
                                                color: Colors
                                                    .white), // Adjust text color
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // 5-Day Forecast
                                const Text(
                                  '5-Day Forecast:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _filteredForecastData!.length,
                                  itemBuilder: (context, index) {
                                    final forecast =
                                        _filteredForecastData![index];
                                    final date =
                                        DateTime.parse(forecast['dt_txt']);
                                    final day = DateFormat('EEEE').format(date);
                                    final temp = forecast['main']['temp'];
                                    final description =
                                        forecast['weather'][0]['description'];
                                    final icon = forecast['weather'][0]['icon'];

                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF003366),
                                            Color(0xFF607D8B),
                                          ], // Gradient colors
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            8), // Optional, for rounded corners
                                      ),
                                      child: Card(
                                        color: Colors
                                            .transparent, // Ensure the card itself is transparent
                                        child: ListTile(
                                          leading: Image.network(
                                            'https://openweathermap.org/img/wn/$icon@2x.png',
                                          ),
                                          title: Text('$day',
                                              style: const TextStyle(
                                                  color: Colors
                                                      .white)), // Text color adjusted to white
                                          subtitle: Text(
                                            '${temp.toStringAsFixed(1)}°C, $description',
                                            style: const TextStyle(
                                                color: Colors
                                                    .white), // Text color adjusted to white
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Enter a city to see weather info.',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
