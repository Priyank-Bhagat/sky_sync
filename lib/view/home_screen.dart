import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';
import 'package:intl/intl.dart';

import '../repo/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<WeatherBloc>().add(FetchWeatherEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size device = MediaQuery.of(context).size;

    return SafeArea(
      child: Stack(
        children: [
          BlocBuilder<WeatherBloc, WeatherState>(builder: (context, state) {
            if (state is WeatherLoadingState) {
              return Container(
                  color: Colors.black12,
                  width: device.width,
                  height: device.height);
            } else if (state is WeatherLoadFailState) {
              return Container(
                  color: Colors.black12,
                  width: device.width,
                  height: device.height);
            } else if (state is WeatherLoadedState) {
              WeatherType weatherConditon = getWeatherCondition(
                  state.weatherModel.current!.condition!.code as int);

              return WeatherBg(
                  weatherType: weatherConditon,
                  width: device.width,
                  height: device.height);
            } else {
              return Container(
                  color: Colors.black12,
                  width: device.width,
                  height: device.height);
            }
          }),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoadingState) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 400),
                        child: LoadingAnimationWidget.inkDrop(
                            color: Colors.white, size: 40),
                      ),
                    );
                  } else if (state is WeatherLoadFailState) {
                    return Container(
                      child: Text('Failedddddd'),
                    );
                  } else if (state is WeatherLoadedState) {
                    String formatDate(String dateTimeStr) {
                      DateTime dateTime = DateTime.parse(dateTimeStr);
                      DateFormat formatter = DateFormat('EEE, dd MMMM');
                      return formatter.format(dateTime);
                    }

                    String formattedDate = formatDate(
                        state.weatherModel.current!.lastUpdated as String);

                    return Column(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
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
                                formattedDate,
                                style: GoogleFonts.merriweather(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // const Icon(
                              //   Icons.cloud,
                              //   size: 60,
                              //   color: Colors.red,
                              // ),
                              Image.network(
                                'https://${state.weatherModel.current!.condition!.icon.toString().substring(2)}',
                                height: 80,
                                fit: BoxFit.fitHeight,
                              ),
                              const SizedBox(
                                width: 20,
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
                          state.weatherModel.current!.condition!.text
                              .toString(),
                          style: GoogleFonts.merriweather(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, bottom: 12.0, top: 82),
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 0, left: 18, right: 18),
                            height: 155,
                            width: device.width,
                            decoration: const BoxDecoration(
                                color: Color(0x661d3f46),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              itemBuilder: (BuildContext context, int index) {
                                return const Padding(
                                  padding: EdgeInsets.only(
                                      top: 32,
                                      left: 14.0,
                                      right: 14.0,
                                      bottom: 14.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        '00:00',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        Icons.cloud,
                                        size: 22,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '💧 75%',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                    height: 10,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: const VerticalDivider(
                                      thickness: 0.0,
                                      color: Colors.white,
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
                                top: 18, left: 18, right: 18),
                            height: 170,
                            width: device.width,
                            decoration: const BoxDecoration(
                                color: Color(0x661d3f46),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (BuildContext context, int index) {
                                return const Padding(
                                  padding:
                                      EdgeInsets.only(top: 0, bottom: 14.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Wed',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        Icons.cloud,
                                        size: 26,
                                        color: Colors.red,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          'Patchy rain, possible',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                    height: 10,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: const VerticalDivider(
                                      thickness: 0.0,
                                      color: Colors.white,
                                      width: 20,
                                    ));
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
