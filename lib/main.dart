import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_sync/view/home_screen.dart';
import 'package:sky_sync/view/splash_screen.dart';
import 'package:sky_sync/viewModel/bloc/citySearch/city_search_bloc.dart';

import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WeatherBloc(),
        ),
        BlocProvider(
          create: (context) => CitySearchBloc(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: SplashScreen(
          lastScreenName: 'MyApp',
        ),
      ),
    );
  }
}
