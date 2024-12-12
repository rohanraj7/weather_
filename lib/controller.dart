import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String apiUrl = 'https://api.openweathermap.org/data/2.5/';
const String apiKey = 'c19f22cae178e39e4a10131dcc393a7a';

class WeatherController extends GetxController {
  var cityController = TextEditingController();
  var currentWeather = Rxn<Map<String, dynamic>>();
  var filteredForecastData = Rxn<List<dynamic>>();
  var errorMessage = RxnString();
  var isLoading = false.obs;

  Future<void> fetchWeather(String city) async {
    isLoading.value = true;
    currentWeather.value = null;
    filteredForecastData.value = null;
    errorMessage.value = null;

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
        filteredForecastData.value = _filterForecast(forecastData);
        currentWeather.value = json.decode(currentWeatherResponse.body);
      } else {
        errorMessage.value = 'City not found or API error';
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch weather data';
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _filterForecast(List<dynamic> forecastData) {
    Map<String, Map<String, dynamic>> dailyForecast = {};

    for (var forecast in forecastData) {
      final date = DateTime.parse(forecast['dt_txt']);
      final day = DateFormat('yyyy-MM-dd').format(date);
      final hour = date.hour;

      if (!dailyForecast.containsKey(day) || (hour == 12)) {
        dailyForecast[day] = forecast;
      }
    }

    return dailyForecast.values.toList();
  }
}
