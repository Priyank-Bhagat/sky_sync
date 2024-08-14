import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/bg/weather_bg.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatelessWidget {
  final Size deviceSize;
  const LoadingScreen({super.key, required this.deviceSize});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            WeatherBg(
                weatherType: WeatherType.cloudyNight,
                width: deviceSize.width,
                height: deviceSize.height),
            Shimmer.fromColors(
              baseColor: const Color(0x661d3f46),
              highlightColor: const Color(0x991d3f46),
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
                    width: deviceSize.width * 0.3,
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
                      padding:
                          const EdgeInsets.only(top: 0, left: 18, right: 18),
                      height: 155,
                      width: deviceSize.width,
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
                      width: deviceSize.width,
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
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Shimmer.fromColors(
                baseColor: const Color(0x661d3f46),
                highlightColor: const Color(0x991d3f46),
                child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    width: 60,
                    height: 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
