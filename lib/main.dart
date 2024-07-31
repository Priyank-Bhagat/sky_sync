import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_sync/view/home_screen.dart';
import 'package:sky_sync/view/splash_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => WeatherBloc(),
        child: const HomeScreen(),
      ), //SplashScreen(),
    );
  }
}
