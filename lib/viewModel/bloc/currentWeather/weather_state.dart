part of 'weather_bloc.dart';

@immutable
abstract class WeatherState {}

class WeatherInitialState extends WeatherState {}

class WeatherLoadingState extends WeatherState {}

class WeatherLoadedState extends WeatherState {
  final CurrentWeatherModel weatherModel;

  WeatherLoadedState({required this.weatherModel});
}

class WeatherLoadFailState extends WeatherState {}
