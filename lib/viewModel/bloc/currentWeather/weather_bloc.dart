import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sky_sync/model/current_weather_model.dart';
import 'package:sky_sync/repo/repositories.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  Repositories repo = Repositories();

  WeatherBloc() : super(WeatherInitialState()) {
    on<WeatherEvent>((event, emit) async {
      if (event is FetchWeatherEvent) {
        emit.call(WeatherLoadingState());

        try {
          await repo
              .getCurrentWeather(newLocationReq: event.newLocationReq)
              .then((value) {
            emit.call(WeatherLoadedState(weatherModel: value));
          }).onError((error, stacktrace) {
            debugPrint('error:- $error , at------> $stacktrace');
            emit.call(WeatherLoadFailState());
          });
        } catch (e) {
          rethrow;
        }
      }
    });
  }
}
