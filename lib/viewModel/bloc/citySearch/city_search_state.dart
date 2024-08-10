part of 'city_search_bloc.dart';

@immutable
abstract class CitySearchState {}

class CitySearchInitialState extends CitySearchState {}

class CitiesLoadingState extends CitySearchState {}

class CitiesLoadedState extends CitySearchState {
  final List<CitySearchModel> citySearchModel;

  CitiesLoadedState({required this.citySearchModel});
}

class CitiesFailedState extends CitySearchState {}
