import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../viewModel/bloc/citySearch/city_search_bloc.dart';
import '../home/home_screen.dart';

class CitySearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
          backgroundColor: Color(0x001d3f46), elevation: 0, titleSpacing: 50),
      scaffoldBackgroundColor: const Color(0x664E4565),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20.0, color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(fontSize: 18.0, color: Colors.white60),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Enter city name';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      GestureDetector(
        onTap: () {
          query = '';
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0x661d3f46),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: const Icon(
              Icons.clear,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
            color: Color(0x661d3f46),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResult(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResult(context);
  }

  Widget _buildResult(BuildContext context) {
    if (query.length >= 3) {
      context.read<CitySearchBloc>().add(GetCitiesListEvent(cityName: query));
    }

    if (query.isEmpty) {
      context.read<CitySearchBloc>().add(SearchResetToInitEvent());
    }

    return BlocBuilder<CitySearchBloc, CitySearchState>(
      builder: (context, state) {
        Size device = MediaQuery.of(context).size;
        if (state is CitiesLoadingState) {
          return const Center(
            child: Text(
              'loading',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (state is CitiesLoadedState) {
          var cityResult = state.citySearchModel;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: ListView.builder(
              itemCount: state.citySearchModel.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            cityName:
                                state.citySearchModel[index].name.toString(),
                          ),
                        ),
                        (Route route) => false);
                  },
                  leading: const Icon(
                    Icons.location_city,
                    color: Colors.white,
                  ),
                  title: Text(
                    cityResult[index].name.toString(),
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${cityResult[index].region.toString()} , ${cityResult[index].country.toString()}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Lat : (${cityResult[index].lat.toString()})',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        'Lon : (${cityResult[index].lon.toString()})',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                );
                // ListTile to display each result
              },
            ),
          );
        } else if (state is CitySearchInitialState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
              ),
              Image.asset(
                'assets/images/citys.png',
                width: device.width - 40,
                fit: BoxFit.fitWidth,
              ),
              Text(
                'Search your',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, color: Colors.white, letterSpacing: 5),
              ),
              Text(
                'HOME CITY',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 20, color: Colors.white, letterSpacing: 15),
              )
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: double.infinity,
              ),
              Icon(
                Icons.heart_broken_rounded,
                color: Colors.red.shade300,
                size: 100,
              ),
              Text(
                'Something went wrong',
                style:
                    GoogleFonts.dancingScript(fontSize: 30, color: Colors.red),
              )
            ],
          );
        }
      },
    );
  }
}

class CitySearchScreen extends StatelessWidget {
  final _searchController = TextEditingController();

  final Size deviceSize;

  final VoidCallback onBackPress;

  CitySearchScreen(
      {super.key, required this.deviceSize, required this.onBackPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBackPress,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0x661d3f46),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              SizedBox(
                width: deviceSize.width * 0.5,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (searchString) {
                    if (_searchController.text.length >= 3) {
                      context
                          .read<CitySearchBloc>()
                          .add(GetCitiesListEvent(cityName: searchString));
                    }

                    if (_searchController.text.isEmpty) {
                      context
                          .read<CitySearchBloc>()
                          .add(SearchResetToInitEvent());
                    }
                  },
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    decorationThickness: 0,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter city name',
                    hintStyle: TextStyle(fontSize: 18.0, color: Colors.white60),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0x661d3f46),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: const Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: BlocBuilder<CitySearchBloc, CitySearchState>(
            builder: (context, state) {
          if (state is CitiesLoadingState) {
            return const Center(
              child: Text(
                'loading',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (state is CitiesLoadedState) {
            var cityResult = state.citySearchModel;

            return ListView.builder(
              itemCount: state.citySearchModel.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    decoration: const BoxDecoration(
                      color: Color(0x661d3f46),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                cityName: state.citySearchModel[index].name
                                    .toString(),
                              ),
                            ),
                            (Route route) => false);
                      },
                      leading: const Icon(
                        Icons.location_city,
                        color: Colors.white,
                      ),
                      title: Text(
                        cityResult[index].name.toString(),
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      subtitle: Text(
                        '${cityResult[index].region.toString()} , ${cityResult[index].country.toString()}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Lat : (${cityResult[index].lat.toString()})',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          Text(
                            'Lon : (${cityResult[index].lon.toString()})',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                // ListTile to display each result
              },
            );
          } else if (state is CitySearchInitialState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: double.infinity,
                ),
                Image.asset(
                  'assets/images/citys.png',
                  width: deviceSize.width - 40,
                  fit: BoxFit.fitWidth,
                ),
                Text(
                  'Search your',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20, color: Colors.white, letterSpacing: 5),
                ),
                Text(
                  'HOME CITY',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20, color: Colors.white, letterSpacing: 15),
                )
              ],
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: double.infinity,
                ),
                Icon(
                  Icons.heart_broken_rounded,
                  color: Colors.red.shade300,
                  size: 100,
                ),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.dancingScript(
                      fontSize: 30, color: Colors.red),
                )
              ],
            );
          }
        })),
      ],
    );
  }
}
