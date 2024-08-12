import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:sky_sync/model/current_weather_model.dart';
import 'package:sky_sync/model/city_search_model.dart';
import '../model/position_model.dart';

const String apiKey = 'd89d5ca7edc14da7b84103218243007';

class RepoForWeather {
  static String baseUrl = 'http://api.weatherapi.com/v1/forecast.json';
  static int forecastDays = 5;

  Future<CurrentWeatherModel> getCurrentWeather({String? cityName}) async {
    PositionModel? position;
    String url;

    if (cityName == null) {
      // Determine coordinates
      position = await _determinePosition();

      url = _constructUrl(lat: position!.latitude, lon: position.longitude);
    } else {
      url = _constructUrl(cityName: cityName);
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

  String _constructUrl({double? lat, double? lon, String? cityName}) {
    if (lat != null && lon != null) {
      return '$baseUrl?key=$apiKey&q=$lat,$lon&days=$forecastDays&aqi=no';
    } else if (cityName != null) {
      return '$baseUrl?key=$apiKey&q=$cityName&days=$forecastDays&aqi=no';
    } else {
      throw ArgumentError('Either lat/lon or location must be provided.');
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

      return PositionModel(
        latitude: position.latitude!.toDouble(),
        longitude: position.longitude!.toDouble(),
        cityName: '',
      );
    } else {
      return null;
    }
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
