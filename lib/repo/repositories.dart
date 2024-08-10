import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:sky_sync/model/current_weather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/position_model.dart';

class Repositories {
  static const String apiKey = 'd89d5ca7edc14da7b84103218243007';
  static String baseUrl = 'http://api.weatherapi.com/v1/forecast.json';
  static int forecastDays = 5;

  Future<CurrentWeatherModel> getCurrentWeather(
      {required String newLocationReq}) async {
    PositionModel? position;
    position = await _fetchLocationFromSharePref();

    // Determine coordinates

    if (newLocationReq == 'yes') {
      position = await _determinePosition();
    } else {
      position ??= await _determinePosition();
    }

    // HTTP Req
    final String url =
        '$baseUrl?key=$apiKey&q=${position!.latitude},${position.longitude}&days=$forecastDays&aqi=no';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CurrentWeatherModel.fromJson(data);
    } else {
      throw Exception('Failed to load weather data: ${response.reasonPhrase}');
    }
  }

  Future<PositionModel?> _determinePosition() async {
    final loc.Location location = loc.Location();
    bool isLocationEnabled = await location.serviceEnabled();

    if (!isLocationEnabled) {
      isLocationEnabled = await location.requestService();

      if (!isLocationEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    // Get current location
    if (isLocationEnabled) {
      final position =
          await Future.delayed(const Duration(milliseconds: 100), () {
        return location.getLocation();
      });

      _storeLocation(
          position.latitude!.toDouble(), position.longitude!.toDouble());

      return PositionModel(
        latitude: position.latitude!.toDouble(),
        longitude: position.longitude!.toDouble(),
      );
    } else {
      return null;
    }
  }

  Future<void> _storeLocation(double latitude, double longitude) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
  }

  Future<PositionModel?> _fetchLocationFromSharePref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble('latitude');
    final double? longitude = prefs.getDouble('longitude');

    return PositionModel(
        latitude: latitude!.toDouble(), longitude: longitude!.toDouble());
  }
}
