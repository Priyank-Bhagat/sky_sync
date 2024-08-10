part of 'weather_bloc.dart';

@immutable
abstract class WeatherEvent {}

class FetchWeatherEvent extends WeatherEvent {
  String newLocationReq;
  String cityName;

  FetchWeatherEvent({required this.newLocationReq ,required this.cityName});
}
