import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import '../view/splash_screen.dart';

// Location Logic
class LocationAndPermissions {
  Future<void> checkLocationPermissionsAndServices() async {
    var permissionStatus = await Permission.location.status;
    final loc.Location location = loc.Location();
    bool isLocationEnabled = await location.serviceEnabled();

    if (permissionStatus.isGranted) {
      if (isLocationEnabled) {
        _navigateToHome();
      } else {
        await _handleLocationServiceRequest(location);
      }
    } else if (permissionStatus.isDenied) {
      await _handleLocationPermissionRequest(location);
    } else {
      _showLocationDeniedDialog('Location Permission Required',
          'Location permissions are permanently denied; we cannot request permissions.');
    }
  }

  Future<void> _handleLocationServiceRequest(loc.Location location) async {
    bool isLocationEnabled = await location.requestService();
    if (isLocationEnabled) {
      _navigateToHome();
    } else {
      _showLocationDeniedDialog('Location Service Disabled',
          'Please enable location service, or set location manually.');
    }
  }

  Future<void> _handleLocationPermissionRequest(loc.Location location) async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      bool isLocationEnabled = await location.serviceEnabled();
      if (isLocationEnabled) {
        _navigateToHome();
      } else {
        await _handleLocationServiceRequest(location);
      }
    } else {
      _showLocationDeniedDialog('Location Permission Required',
          'Location permissions are denied. Please enable the permissions to proceed.');
    }
  }

  void _navigateToHome() {
    if (navigatorKey.currentContext != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => SplashScreen(
              lastScreenName: '',
            ),
          ),
          (Route route) => false);
    }
  }

  void _showLocationDeniedDialog(String title, String message) {
    showDialog(
      context: navigatorKey.currentContext as BuildContext,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1d3f46),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              if (title == 'Location Permission Required') {
                await openAppSettings();
              }

              if (!context.mounted) return;

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// Weather Ui logic ----------------------------------------------
const Map<int, WeatherType> dayIconCodeToWeatherCondition = {
  1000: WeatherType.sunny,
  1003: WeatherType.cloudy,
  1006: WeatherType.cloudy,
  1009: WeatherType.overcast,
  1030: WeatherType.hazy,
  1063: WeatherType.middleRainy,
  1066: WeatherType.lightSnow,
  1069: WeatherType.lightSnow,
  1072: WeatherType.lightSnow,
  1087: WeatherType.thunder,
  1114: WeatherType.lightSnow,
  1117: WeatherType.heavySnow,
  1135: WeatherType.foggy,
  1147: WeatherType.foggy,
  1150: WeatherType.lightRainy,
  1153: WeatherType.lightRainy,
  1168: WeatherType.lightSnow,
  1171: WeatherType.heavySnow,
  1180: WeatherType.lightRainy,
  1183: WeatherType.lightRainy,
  1186: WeatherType.middleRainy,
  1189: WeatherType.middleRainy,
  1192: WeatherType.heavyRainy,
  1195: WeatherType.heavyRainy,
  1198: WeatherType.lightSnow,
  1201: WeatherType.heavySnow,
  1204: WeatherType.lightSnow,
  1207: WeatherType.heavySnow,
  1210: WeatherType.lightSnow,
  1213: WeatherType.lightSnow,
  1216: WeatherType.middleSnow,
  1219: WeatherType.middleSnow,
  1222: WeatherType.heavySnow,
  1225: WeatherType.heavySnow,
  1237: WeatherType.lightSnow,
  1240: WeatherType.lightRainy,
  1243: WeatherType.middleRainy,
  1246: WeatherType.heavyRainy,
  1249: WeatherType.lightSnow,
  1252: WeatherType.heavySnow,
  1255: WeatherType.lightSnow,
  1258: WeatherType.heavySnow,
  1261: WeatherType.lightSnow,
  1264: WeatherType.heavySnow,
  1273: WeatherType.lightRainy,
  1276: WeatherType.heavyRainy,
  1279: WeatherType.lightSnow,
  1282: WeatherType.heavySnow,
};

const Map<int, WeatherType> nightIconCodeToWeatherCondition = {
  1000: WeatherType.sunnyNight,
  1003: WeatherType.cloudyNight,
  1006: WeatherType.cloudyNight,
  1009: WeatherType.overcast,
  1030: WeatherType.hazy,
  1063: WeatherType.middleRainy,
  1066: WeatherType.lightSnow,
  1069: WeatherType.lightSnow,
  1072: WeatherType.lightSnow,
  1087: WeatherType.thunder,
  1114: WeatherType.lightSnow,
  1117: WeatherType.heavySnow,
  1135: WeatherType.foggy,
  1147: WeatherType.foggy,
  1150: WeatherType.lightRainy,
  1153: WeatherType.lightRainy,
  1168: WeatherType.lightSnow,
  1171: WeatherType.heavySnow,
  1180: WeatherType.lightRainy,
  1183: WeatherType.lightRainy,
  1186: WeatherType.middleRainy,
  1189: WeatherType.middleRainy,
  1192: WeatherType.heavyRainy,
  1195: WeatherType.heavyRainy,
  1198: WeatherType.lightSnow,
  1201: WeatherType.heavySnow,
  1204: WeatherType.lightSnow,
  1207: WeatherType.heavySnow,
  1210: WeatherType.lightSnow,
  1213: WeatherType.lightSnow,
  1216: WeatherType.middleSnow,
  1219: WeatherType.middleSnow,
  1222: WeatherType.heavySnow,
  1225: WeatherType.heavySnow,
  1237: WeatherType.lightSnow,
  1240: WeatherType.lightRainy,
  1243: WeatherType.middleRainy,
  1246: WeatherType.heavyRainy,
  1249: WeatherType.lightSnow,
  1252: WeatherType.heavySnow,
  1255: WeatherType.lightSnow,
  1258: WeatherType.heavySnow,
  1261: WeatherType.lightSnow,
  1264: WeatherType.heavySnow,
  1273: WeatherType.lightRainy,
  1276: WeatherType.heavyRainy,
  1279: WeatherType.lightSnow,
  1282: WeatherType.heavySnow,
};

WeatherType getWeatherCondition(int iconCode, int mode) {
  if (mode == 1) {
    return dayIconCodeToWeatherCondition[iconCode] ?? WeatherType.sunny;
  } else {
    return nightIconCodeToWeatherCondition[iconCode] ?? WeatherType.sunnyNight;
  }
}
