import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_sync/view/home_screen.dart';
import 'package:sky_sync/viewModel/bloc/currentWeather/weather_bloc.dart';
import 'package:location/location.dart' as loc;
import 'package:sky_sync/repo/utils.dart';

class SplashScreen extends StatefulWidget {
  String lastScreenName;

  SplashScreen({super.key, required this.lastScreenName});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () async {
        if (widget.lastScreenName == 'MyApp') {
          _checker();
        } else {
          bool isLocationEnabled = await loc.Location().serviceEnabled();
          isLocationEnabled
              ? Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => WeatherBloc(),
                      child: const HomeScreen(),
                    ),
                  ),
                  (Route route) => false)
              : {isLocationEnabled = await loc.Location().requestService()};
        }
      },
    );
  }

  void _checker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? latitude = prefs.getDouble('latitude');
    final double? longitude = prefs.getDouble('longitude');

    if (latitude != null && longitude != null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => WeatherBloc(),
              child: const HomeScreen(),
            ),
          ),
          (Route route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => WeatherBloc(),
              child: WelcomeScreen(),
            ),
          ),
          (Route route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x661d3f46),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: double.infinity,
          ),
          Image.asset(
            'assets/images/loader.gif',
            height: 250,
            width: 250,
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final permissionHandler = LocationAndPermissions();
  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size device = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0x661d3f46),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bgimg.jpg',
            height: device.height,
            width: device.width,
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/loader.gif',
                height: 250,
                width: 250,
              ),
              const SizedBox(
                height: 270,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Allow SkySync to provide you with the most accurate forecast by allowing us to use your device\'s location.',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 130),
                child: ElevatedButton(
                  onPressed: () {
                    permissionHandler.checkLocationPermissionsAndServices();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // <-- Radius
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          color: Color(0xff1d3f46),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      Icon(
                        Icons.location_pin,
                        color: Color(0xff1d3f46),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50, top: 20),
                child: Text(
                  'Set city manually',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
