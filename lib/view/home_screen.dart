import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sky_sync/view/splash_screen.dart';
import 'package:sky_sync/view/widgets/animated_floating_menu.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';
import 'package:intl/intl.dart';

import '../model/current_weather_model.dart';
import '../repo/utils.dart';

class HomeScreen extends StatefulWidget {
  final String cityName;
   HomeScreen({super.key, required this.cityName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    if(widget.cityName == ''){

      context.read<WeatherBloc>().add(FetchWeatherEvent(newLocationReq: 'no', cityName: ''));
    }else{
      context.read<WeatherBloc>().add(FetchWeatherEvent(newLocationReq: 'no', cityName: widget.cityName));
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
            return _loadedScreen(state, device);
          } else {
            return _brokenScreen();
          }
        },
      ),
    );
  }

  Widget _loadedScreen(WeatherLoadedState state, Size device) {
    WeatherType weatherConditon = getWeatherCondition(
        state.weatherModel.current!.condition!.code as int,
        state.weatherModel.current!.isDay as int);

    String formatDate(String dateTimeStr, String type) {
      if (type == 'EEE') {
        DateTime dateTime = DateTime.parse(dateTimeStr);
        DateFormat formatter = DateFormat('EEE, dd MMMM');
        return formatter.format(dateTime);
      } else {
        DateTime dateTime = DateTime.parse(dateTimeStr);
        DateFormat formatter = DateFormat('dd/MM HH:mm');
        return formatter.format(dateTime);
      }
    }

    String todayDay =
        formatDate(state.weatherModel.current!.lastUpdated as String, 'EEE');

    String lastUpdateTime = formatDate(
        state.weatherModel.current!.lastUpdated as String, 'nothing');

    return Stack(
      children: [
        WeatherBg(
            weatherType: weatherConditon,
            width: device.width,
            height: device.height),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
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
                        state.weatherModel.location!.name.toString(),
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
                        'https://${state.weatherModel.current!.condition!.icon.toString().substring(2)}',
                        height: 100,
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${state.weatherModel.current!.tempC} °',
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
                  'Feels like  ${state.weatherModel.current!.feelslikeC} °',
                  style: GoogleFonts.merriweather(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  state.weatherModel.current!.condition!.text.toString(),
                  style: GoogleFonts.merriweather(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 65, left: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Last Updated $lastUpdateTime',
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
                      itemCount: state
                          .weatherModel.forecast!.forecastday![0].hour!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 32, left: 14.0, right: 14.0, bottom: 10.0),
                          child: Column(
                            children: [
                              Text(
                                state.weatherModel.forecast!.forecastday![0]
                                    .hour![index].time!
                                    .substring(11),
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Image.network(
                                'https://${state.weatherModel.forecast!.forecastday![0].hour![index].condition!.icon!.substring(2)}',
                                height: 50,
                                width: 70,
                                fit: BoxFit.contain,
                              ),
                              // const SizedBox(
                              //   height: 5,
                              // ),
                              Text(
                                '💧 ${state.weatherModel.forecast!.forecastday![0].hour![index].chanceOfRain}%',
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
                      itemCount:
                          state.weatherModel.forecast!.forecastday!.length,
                      itemBuilder: (BuildContext context, int index) {
                        String formatDate(String dateTimeStr) {
                          DateTime dateTime = DateTime.parse(dateTimeStr);
                          DateFormat formatter = DateFormat('EEE');
                          return formatter.format(dateTime);
                        }

                        String formattedDate = formatDate(state.weatherModel
                            .forecast!.forecastday?[index].date as String);

                        return Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 14.0),
                          child: Column(
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Image.network(
                                'https://${state.weatherModel.forecast!.forecastday?[index].day!.condition!.icon!.substring(2)}',
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
                                  state
                                      .weatherModel
                                      .forecast!
                                      .forecastday?[index]
                                      .day!
                                      .condition!
                                      .text as String,
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
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: AnimatedFAB(
            locationOnPressed: () {
              context
                  .read<WeatherBloc>()
                  .add(FetchWeatherEvent(newLocationReq: 'yes', cityName: ''));
              // showSearch(context: context, delegate: MySearchDelegant());
            },
          ),
          // child: GestureDetector(
          //   onTap: () {
          //     context
          //         .read<WeatherBloc>()
          //         .add(FetchWeatherEvent(newLocationReq: 'yes'));
          //     // showSearch(context: context, delegate: MySearchDelegant());
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: const BoxDecoration(
          //         color: Color(0x661d3f46),
          //         borderRadius: BorderRadius.all(Radius.circular(20))),
          //     child: const Icon(
          //       Icons.location_pin,
          //       color: Colors.white,
          //       size: 32,
          //     ),
          //   ),
          // ),
        ),
      ],
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
                  builder: (context) => SplashScreen(
                    lastScreenName: '',
                  ),
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
    return Stack(
      children: [
        WeatherBg(
            weatherType: WeatherType.cloudyNight,
            width: device.width,
            height: device.height),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
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
        ),
      ],
    );
  }
}
