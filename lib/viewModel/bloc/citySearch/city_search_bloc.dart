import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:sky_sync/model/city_search_model.dart';
import 'package:sky_sync/repo/repositories.dart';

part 'city_search_event.dart';
part 'city_search_state.dart';

class CitySearchBloc extends Bloc<CitySearchEvent, CitySearchState> {
  RepoForSearchCity repo = RepoForSearchCity();

  CitySearchBloc() : super(CitySearchInitialState()) {
    on<CitySearchEvent>((event, emit) async {
      if (event is GetCitiesListEvent) {
        emit.call(CitiesLoadingState());

        try {
          await repo
              .getCitiesSuggestions(cityQuery: event.cityName)
              .then((value) {
            emit.call(CitiesLoadedState(citySearchModel: value));
          }).onError((error, stacktrace) {
            debugPrint('error:- $error , at------> $stacktrace');
            emit.call(CitiesFailedState());
          });
        } catch (e) {
          rethrow;
        }
      }

      if (event is SearchResetToInitEvent) {
        emit.call(CitySearchInitialState());
      }
    });
  }
}
