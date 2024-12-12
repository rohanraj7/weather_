import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller.dart';

class WeatherScreen extends StatelessWidget {
  final WeatherController weatherController = Get.put(WeatherController());

  WeatherScreen({super.key});

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
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              TextField(
                controller: weatherController.cityController,
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
                      weatherController
                          .fetchWeather(weatherController.cityController.text);
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (weatherController.isLoading.value) {
                  return const CircularProgressIndicator(color: Colors.white);
                }
                if (weatherController.errorMessage.value != null) {
                  return Text(
                    weatherController.errorMessage.value!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  );
                }
                if (weatherController.currentWeather.value != null &&
                    weatherController.filteredForecastData.value != null) {
                  return Expanded(
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
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Card(
                              color: Colors.transparent,
                              elevation: 6,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Weather in ${weatherController.currentWeather.value!['name']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Temperature: ${weatherController.currentWeather.value!['main']['temp']}°C',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Humidity: ${weatherController.currentWeather.value!['main']['humidity']}%',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Wind Speed: ${weatherController.currentWeather.value!['wind']['speed']} m/s',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 5-Day Forecast
                          const Text(
                            '6-Day Forecast:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: weatherController
                                .filteredForecastData.value!.length,
                            itemBuilder: (context, index) {
                              final forecast = weatherController
                                  .filteredForecastData.value![index];
                              final date = DateTime.parse(forecast['dt_txt']);
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
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Card(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    leading: Image.network(
                                      'https://openweathermap.org/img/wn/$icon@2x.png',
                                    ),
                                    title: Text(
                                      '$day',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '${temp.toStringAsFixed(1)}°C, $description',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Text(
                  'Enter a city to see weather info.',
                  style: TextStyle(color: Colors.white),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
