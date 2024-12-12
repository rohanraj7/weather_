import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';

const String apiUrl = 'https://api.openweathermap.org/data/2.5/';
const String apiKey = 'c19f22cae178e39e4a10131dcc393a7a';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}
