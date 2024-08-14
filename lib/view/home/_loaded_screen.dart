import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sky_sync/view/widgets/animated_floating_menu.dart';
import 'package:sky_sync/view/widgets/city_searchbar_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';
import '../../repo/utils.dart';

class LoadedScreen extends StatefulWidget {
  final WeatherLoadedState state;
  final Size deviceSize;
  const LoadedScreen(
      {super.key, required this.state, required this.deviceSize});

  @override
  State<LoadedScreen> createState() => _LoadedScreenState();
}

class _LoadedScreenState extends State<LoadedScreen> {
  final _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WeatherType weatherCondition = getWeatherCondition(
        widget.state.weatherModel.current!.condition!.code as int,
        widget.state.weatherModel.current!.isDay as int);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          WeatherBg(
              weatherType: weatherCondition,
              width: widget.deviceSize.width,
              height: widget.deviceSize.height),
          PageView(
            controller: _pageController,
            children: [
              _weatherPage(state: widget.state, deviceSize: widget.deviceSize),
              _searchPage(
                  deviceSize: widget.deviceSize,
                  onBackPress: () {
                    _pageController.jumpToPage(0);
                  }),
            ],
          ),
          Visibility(
            visible: _currentPage == 0,
            child: Positioned(
              top: 10,
              left: 10,
              child: AnimatedFAB(
                locationOnPressed: () {
                  context.read<WeatherBloc>().add(FetchWeatherEvent());
                },
                mapOnPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherPage(
      {required WeatherLoadedState state, required Size deviceSize}) {
    final current = state.weatherModel.current!;

    final forcastHourly = state.weatherModel.forecast!.forecastday![0].hour!;

    final forcastDaily = state.weatherModel.forecast!.forecastday!;

    String cityName = state.weatherModel.location!.name.toString();

    String todayDay = formatDate(current.lastUpdated as String, 'EdM');

    String imgUrl =
        'https://${current.condition!.icon.toString().substring(2)}';

    String temperature = '${current.tempC} °';

    String feelsLikeTemp = 'Feels like  ${current.feelslikeC} °';

    String currentCondition = current.condition!.text.toString();

    String lastUpdateTime =
        'Last Updated ${formatDate(current.lastUpdated as String, 'dMHm')}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: deviceSize.height * 0.1,
            width: double.infinity,
          ),
          Container(
            padding: const EdgeInsets.all(18),
            width: deviceSize.width * 0.5,
            decoration: const BoxDecoration(
                color: Color(0x661d3f46),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cityName,
                  style: GoogleFonts.merriweather(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: double.infinity,
                  height: 6,
                ),
                Text(
                  todayDay,
                  style: GoogleFonts.merriweather(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w200),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  imgUrl,
                  height: 100,
                  width: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  temperature,
                  style: GoogleFonts.merriweather(
                      fontSize: 60,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            feelsLikeTemp,
            style: GoogleFonts.merriweather(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            currentCondition,
            style: GoogleFonts.merriweather(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 65, left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  lastUpdateTime,
                  style: GoogleFonts.merriweather(
                      fontSize: 16,
                      color: Colors.white.withOpacity(.4),
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: 12.0, right: 12.0, bottom: 12.0, top: 20),
            child: Container(
              padding: const EdgeInsets.only(top: 0, left: 18, right: 18),
              height: 155,
              width: deviceSize.width,
              decoration: const BoxDecoration(
                  color: Color(0x661d3f46),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: forcastHourly.length,
                itemBuilder: (BuildContext context, int index) {
                  String hourlyTime = forcastHourly[index].time!.substring(11);

                  String hourlyTimeImg =
                      'https://${forcastHourly[index].condition!.icon!.substring(2)}';

                  String chanceOfRain =
                      '💧 ${forcastHourly[index].chanceOfRain}%';

                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 32, left: 14.0, right: 14.0, bottom: 10.0),
                    child: Column(
                      children: [
                        Text(
                          hourlyTime,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Image.network(
                          hourlyTimeImg,
                          height: 50,
                          width: 70,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          chanceOfRain,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                      height: 10,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: VerticalDivider(
                        thickness: 1.0,
                        color: Colors.white.withOpacity(0.4),
                        width: 20,
                      ));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 5, left: 18, right: 18, bottom: 10),
              height: 180,
              width: deviceSize.width,
              decoration: const BoxDecoration(
                  color: Color(0x661d3f46),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: forcastDaily.length,
                itemBuilder: (BuildContext context, int index) {
                  String forcastDays =
                      formatDate(forcastDaily[index].date as String, 'EEE');

                  String forcastDaysImg =
                      'https://${forcastDaily[index].day!.condition!.icon!.substring(2)}';

                  String forcastCondition =
                      forcastDaily[index].day!.condition!.text as String;

                  return Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 14.0),
                    child: Column(
                      children: [
                        Text(
                          forcastDays,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Image.network(
                          forcastDaysImg,
                          height: 50,
                          width: 70,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            forcastCondition,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 10,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: VerticalDivider(
                      thickness: 1.0,
                      color: Colors.white.withOpacity(0.4),
                      width: 20,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchPage(
      {required Size deviceSize, required VoidCallback onBackPress}) {
    return CitySearchScreen(deviceSize: deviceSize, onBackPress: onBackPress);
  }
}
