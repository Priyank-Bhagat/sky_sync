import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:sky_sync/model/current_weather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../model/position_model.dart';

class Repositories {
  static const String apiKey = 'd89d5ca7edc14da7b84103218243007';
  static String baseUrl = 'http://api.weatherapi.com/v1/forecast.json';
  static int forecastDays = 5;

  Future<CurrentWeatherModel> getCurrentWeather({required String newLocationReq}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble('latitude');
    final double? longitude = prefs.getDouble('longitude');

    PositionModel position;

    // Determine coordinates
    if (newLocationReq == 'yes') {
      position = await determinePosition();
      print('newRequst -------------');
    } else {
      print('old -------------');
      position = (latitude != null && longitude != null)
          ? PositionModel(latitude: latitude, longitude: longitude)
          : await determinePosition();
    }

    final String url =
        '$baseUrl?key=$apiKey&q=${position.latitude},${position.longitude}&days=$forecastDays&aqi=no';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CurrentWeatherModel.fromJson(data);
    } else {
      throw Exception('Failed to load weather data: ${response.reasonPhrase}');
    }
  }

  Future<PositionModel> determinePosition() async {
    if (!await geo.Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled.');
    }

    // Check location permission
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission != geo.LocationPermission.whileInUse &&
          permission != geo.LocationPermission.always) {
        throw Exception('Location permissions are denied.');
      }
    }

    // Get current location
    final geo.Position position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.medium,
    );

    _storeLocation(position.latitude, position.longitude);

    return PositionModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<void> _storeLocation(double latitude, double longitude) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }
}




class LocationAndPermissions {


}
