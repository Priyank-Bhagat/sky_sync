import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:sky_sync/view/home/home_screen.dart';
import '../main.dart';

// Location Logic
class LocationAndPermissions {
  Future<void> checkLocationPermissionsAndServices() async {
    var permissionStatus = await Permission.location.status;
    final loc.Location location = loc.Location();
    bool isLocationEnabled = await location.serviceEnabled();

    if (permissionStatus.isGranted) {
      if (isLocationEnabled) {
        navigateToHome();
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
      navigateToHome();
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
        navigateToHome();
      } else {
        await _handleLocationServiceRequest(location);
      }
    } else {
      _showLocationDeniedDialog('Location Permission Required',
          'Precious Location permissions are denied. Please enable the permissions to proceed.');
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

void navigateToHome() {
  if (navigatorKey.currentContext != null) {
    navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (Route route) => false);
  }
}

// Weather Ui logic ----------------------------------------------

const Map<int, List<WeatherType>> codeToWeatherCondition = {
  1000: [WeatherType.sunny, WeatherType.sunnyNight],
  1003: [WeatherType.cloudy, WeatherType.cloudyNight],
  1006: [WeatherType.cloudy, WeatherType.cloudyNight],
  1009: [WeatherType.overcast, WeatherType.overcast],
  1030: [WeatherType.hazy, WeatherType.hazy],
  1063: [WeatherType.middleRainy, WeatherType.middleRainy],
  1066: [WeatherType.lightSnow, WeatherType.lightSnow],
  1069: [WeatherType.lightSnow, WeatherType.lightSnow],
  1072: [WeatherType.middleSnow, WeatherType.middleSnow],
  1087: [WeatherType.thunder, WeatherType.thunder],
  1114: [WeatherType.middleSnow, WeatherType.middleSnow],
  1117: [WeatherType.heavySnow, WeatherType.heavySnow],
  1135: [WeatherType.foggy, WeatherType.foggy],
  1147: [WeatherType.foggy, WeatherType.foggy],
  1150: [WeatherType.lightRainy, WeatherType.lightRainy],
  1153: [WeatherType.lightRainy, WeatherType.lightRainy],
  1168: [WeatherType.middleRainy, WeatherType.middleRainy],
  1171: [WeatherType.heavyRainy, WeatherType.heavyRainy],
  1180: [WeatherType.lightRainy, WeatherType.lightRainy],
  1183: [WeatherType.lightRainy, WeatherType.lightRainy],
  1186: [WeatherType.middleRainy, WeatherType.middleRainy],
  1189: [WeatherType.middleRainy, WeatherType.middleRainy],
  1192: [WeatherType.thunder, WeatherType.thunder],
  1195: [WeatherType.thunder, WeatherType.thunder],
  1198: [WeatherType.lightRainy, WeatherType.lightRainy],
  1201: [WeatherType.middleRainy, WeatherType.middleRainy],
  1204: [WeatherType.lightSnow, WeatherType.lightSnow],
  1207: [WeatherType.heavySnow, WeatherType.heavySnow],
  1210: [WeatherType.lightSnow, WeatherType.lightSnow],
  1213: [WeatherType.lightSnow, WeatherType.lightSnow],
  1216: [WeatherType.middleSnow, WeatherType.middleSnow],
  1219: [WeatherType.middleSnow, WeatherType.middleSnow],
  1222: [WeatherType.heavySnow, WeatherType.heavySnow],
  1225: [WeatherType.heavySnow, WeatherType.heavySnow],
  1237: [WeatherType.lightSnow, WeatherType.lightSnow],
  1240: [WeatherType.lightRainy, WeatherType.lightRainy],
  1243: [WeatherType.middleRainy, WeatherType.middleRainy],
  1246: [WeatherType.heavyRainy, WeatherType.heavyRainy],
  1249: [WeatherType.lightSnow, WeatherType.lightSnow],
  1252: [WeatherType.heavySnow, WeatherType.heavySnow],
  1255: [WeatherType.lightSnow, WeatherType.lightSnow],
  1258: [WeatherType.heavySnow, WeatherType.heavySnow],
  1261: [WeatherType.lightSnow, WeatherType.lightSnow],
  1264: [WeatherType.heavySnow, WeatherType.heavySnow],
  1273: [WeatherType.thunder, WeatherType.thunder],
  1276: [WeatherType.thunder, WeatherType.thunder],
  1279: [WeatherType.thunder, WeatherType.thunder],
  1282: [WeatherType.thunder, WeatherType.thunder],
};

WeatherType getWeatherCondition(int iconCode, int mode) {
  if (mode == 1) {
    return codeToWeatherCondition[iconCode]![0];
  } else {
    return codeToWeatherCondition[iconCode]![1];
  }
}

String formatDate(String dateTimeStr, String type) {
  if (type == 'EdM') {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    DateFormat formatter = DateFormat('EEE, dd MMMM');
    return formatter.format(dateTime);
  } else if (type == 'dMHm') {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    DateFormat formatter = DateFormat('dd/MM HH:mm');
    return formatter.format(dateTime);
  } else {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    DateFormat formatter = DateFormat('EEE');
    return formatter.format(dateTime);
  }
}
