import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:sky_sync/main.dart';
import 'package:sky_sync/view/home_screen.dart';
import 'package:sky_sync/view/splash_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';

// Weather Ui logic
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

// Location Logic
void showLocationDeniedDialog(String title, String message) {
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
            if (title == 'Location Service Disabled') await openAppSettings();

            if (!context.mounted) return;

            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

Future<void> checkLocationPerNSer() async {
  final location = loc.Location();
  var permissionStatus = await Permission.location.status;
  bool isLocationEnabled = await location.serviceEnabled();

  if (permissionStatus.isGranted) {
    if (isLocationEnabled) {
      _navigateToHome();
    } else {
      isLocationEnabled = await location.requestService();
      isLocationEnabled
          ? _navigateToHome()
          : showLocationDeniedDialog('Location Service Disabled',
              'Please enable location service, otherwise set location manually.');
    }
  } else if (permissionStatus.isDenied) {
    await Permission.location.request();
    permissionStatus = await Permission.location.status;
    if (permissionStatus.isGranted) {
      if (isLocationEnabled) {
        _navigateToHome();
      } else {
        isLocationEnabled = await location.requestService();
        isLocationEnabled
            ? _navigateToHome()
            : showLocationDeniedDialog('Location Service Disabled',
                'Please enable location service, otherwise set location manually.');
      }
    } else {
      showLocationDeniedDialog('Location Permission Required',
          'Location services are disabled. Please enable the services');
    }
  } else {
    showLocationDeniedDialog('Location Permission Required',
        'Location permissions are permanently denied, we cannot request permissions.');
  }
}

void _navigateToHome() {
  if (navigatorKey.currentContext != null) {
    navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>  SplashScreen(lastScreenName: '',),
        ),
        (Route route) => false);
  }
}
