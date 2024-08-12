part of 'weather_bloc.dart';

@immutable
abstract class WeatherEvent {}

class FetchWeatherEvent extends WeatherEvent {
  String? cityName;

  FetchWeatherEvent({this.cityName});
}
