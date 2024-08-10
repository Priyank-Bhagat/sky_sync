part of 'city_search_bloc.dart';

@immutable
abstract class CitySearchEvent {}


class GetCitiesListEvent extends CitySearchEvent {
 final String cityName;

  GetCitiesListEvent({required this.cityName});
}
