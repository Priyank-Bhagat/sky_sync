import 'package:flutter/material.dart';

import 'home_screen.dart';

class BrokenScreen extends StatelessWidget {
  const BrokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}
