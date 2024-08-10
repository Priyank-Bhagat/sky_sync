import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:sky_sync/model/current_weather_model.dart';
import 'package:sky_sync/model/city_search_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/position_model.dart';

const String apiKey = 'd89d5ca7edc14da7b84103218243007';

class RepoForWeather {
  static String baseUrl = 'http://api.weatherapi.com/v1/forecast.json';
  static int forecastDays = 5;

  Future<CurrentWeatherModel> getCurrentWeather(
      {required String newLocationReq, String? cityName}) async {
    PositionModel? position;
    String url;
    position = await _fetchLocationFromSharePref();

    if (cityName == null) {
      // Determine coordinates

      if (newLocationReq == 'yes') {
        position = await _determinePosition();
      } else {
        position ??= await _determinePosition();
      }

      url =
          '$baseUrl?key=$apiKey&q=${position!.latitude},${position.longitude}&days=$forecastDays&aqi=no';
    } else {
      url = '$baseUrl?key=$apiKey&q=$cityName&days=$forecastDays&aqi=no';
    }

    // HTTP Req

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
          position.latitude!.toDouble(), position.longitude!.toDouble(), '');

      return PositionModel(
        latitude: position.latitude!.toDouble(),
        longitude: position.longitude!.toDouble(),
        cityName: '',
      );
    } else {
      return null;
    }
  }

  Future<void> _storeLocation(
      double latitude, double longitude, String? cityName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    if (cityName != null) {
      await prefs.setString('cityName', cityName);
    }
  }

  Future<PositionModel?> _fetchLocationFromSharePref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble('latitude');
    final double? longitude = prefs.getDouble('longitude');
    final String? cityName = prefs.getString('cityName');

    if (latitude != null && longitude != null && cityName == null) {
      return PositionModel(
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
          cityName: '');
    } else if (cityName != null && latitude == null && longitude == null) {
      return PositionModel(latitude: 0, longitude: 0, cityName: '');
    }
    return null;
  }
}

class RepoForSearchCity {
  Future<List<CitySearchModel>> getCitiesSuggestions(
      {required String cityQuery}) async {
    final String url =
        'http://api.weatherapi.com/v1/search.json?key=$apiKey&q=$cityQuery';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => CitySearchModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load weather data: ${response.reasonPhrase}');
    }
  }
}
