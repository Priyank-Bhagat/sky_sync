import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sky_sync/view/widgets/animated_floating_menu.dart';
import 'package:sky_sync/view/widgets/city_searchbar_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';
import '../repo/utils.dart';

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
    Size device = MediaQuery.of(context).size;

    return SafeArea(
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoadingState) {
            return _loadingScreen(device);
          } else if (state is WeatherLoadedState) {
            return LoadedScreen(
              state: state,
              deviceSize: device,
            );
          } else {
            return _brokenScreen();
          }
        },
      ),
    );
  }

  Widget _brokenScreen() {
    return Scaffold(
      backgroundColor: const Color(0xff4E4565),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/broken.gif'),
        const Text(
          'Something unexpected happened.',
          style: TextStyle(
              fontSize: 20, color: Colors.red, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 25,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (Route route) => false);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Color(0x661d3f46),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 32,
            ),
          ),
        )
      ]),
    );
  }

  Widget _loadingScreen(Size device) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          WeatherBg(
              weatherType: WeatherType.cloudyNight,
              width: device.width,
              height: device.height),
          SingleChildScrollView(
              child: Shimmer.fromColors(
            baseColor: const Color(0x661d3f46),
            highlightColor: const Color(0x991d3f46),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: device.height * 0.1,
                  width: double.infinity,
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  width: device.width * 0.5,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0x661d3f46),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  width: device.width * 0.3,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0x661d3f46),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0, bottom: 12.0, top: 20),
                  child: Container(
                    padding: const EdgeInsets.only(top: 0, left: 18, right: 18),
                    height: 155,
                    width: device.width,
                    decoration: const BoxDecoration(
                      color: Color(0x661d3f46),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 5, left: 18, right: 18, bottom: 10),
                    height: 180,
                    width: device.width,
                    decoration: const BoxDecoration(
                      color: Color(0x661d3f46),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}


















class LoadedScreen extends StatefulWidget {
  final WeatherLoadedState state;
  final Size deviceSize;
  LoadedScreen({super.key, required this.state, required this.deviceSize});

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
              _weatherPage(widget.state, widget.deviceSize),
              CityScreen(deviceSize: widget.deviceSize, onBackPress: () {
                _pageController.jumpToPage(0);
              },),
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
                cityOnPressed: () {
                  showSearch(context: context, delegate: CitySearchBarScreen());
                },
                mapOnPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherPage(WeatherLoadedState state, Size device) {
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
            height: device.height * 0.1,
            width: double.infinity,
          ),
          Container(
            padding: const EdgeInsets.all(18),
            width: device.width * 0.5,
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
              width: device.width,
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
              width: device.width,
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
}
