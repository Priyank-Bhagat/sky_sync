import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sky_sync/view/home_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      _navigateToHome();
    } else if (status.isDenied) {
      // If permission is denied, request permission
      await Permission.location.request();
      // After requesting, check the permission status again
      status = await Permission.location.status;
      if (status.isGranted) {
        _navigateToHome();
      } else {
        // Handle permission denial (e.g., show a dialog or a message)
        _showPermissionDeniedDialog('Location services are disabled. Please enable the services');
      }
    } else {
      // Handle other cases, like permanently denied
      _showPermissionDeniedDialog('Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  void _navigateToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => WeatherBloc(),
          child: const HomeScreen(),
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          const Icon(
            Icons.location_disabled,
            size: 40,
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: ()async{
              await  openAppSettings();
            },
            child: const Text(
              'Location Permission Required:- ',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 20),
              width: 300,
              child: const Text(
                  'Resolve it by :- \n -> Give permission manually from Settings app, and then reopen SkySync app.'))
        ],
      ),
    );
  }
}
