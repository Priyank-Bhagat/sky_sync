import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_sync/view/home/_broken_screen.dart';
import 'package:sky_sync/view/home/_loaded_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';
import '_loading_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? cityName;
  const HomeScreen({super.key, this.cityName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    if (widget.cityName == null) {
      context.read<WeatherBloc>().add(FetchWeatherEvent());
    } else {
      context
          .read<WeatherBloc>()
          .add(FetchWeatherEvent(cityName: widget.cityName));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return SafeArea(
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoadingState) {
            return LoadingScreen(
              deviceSize: deviceSize,
            );
          } else if (state is WeatherLoadedState) {
            return LoadedScreen(
              state: state,
              deviceSize: deviceSize,
            );
          } else {
            return const BrokenScreen();
          }
        },
      ),
    );
  }
}
