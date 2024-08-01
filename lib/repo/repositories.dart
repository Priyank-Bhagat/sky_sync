import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sky_sync/model/current_weather_model.dart';

class Repositories {
  Future<CurrentWeatherModel> getCurrentWeather() async {
    Position position = await determinePosition();

    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/forecast.json?key=d89d5ca7edc14da7b84103218243007&q=${position.latitude},${position.longitude}&days=5&aqi=no'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CurrentWeatherModel.fromJson(data);
    }
    throw UnimplementedError();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle the case when location services are not enabled
      throw Exception('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle the case when permission is not granted
        throw Exception('Location permissions are denied.');
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return position;
  }
}
