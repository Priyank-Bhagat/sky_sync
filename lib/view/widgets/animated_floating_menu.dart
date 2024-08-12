import 'package:flutter/material.dart';

class AnimatedFAB extends StatefulWidget {
  final VoidCallback locationOnPressed, cityOnPressed, mapOnPressed;

  const AnimatedFAB(
      {super.key,
      required this.locationOnPressed,
      required this.cityOnPressed,
      required this.mapOnPressed});

  @override
  _AnimatedFABState createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation? degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation? rotationAnimation;

  double getRadiansFromDegree(double degree) {
    return degree * (3.141592653589793 / 180.0);
  }

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));

    degOneTranslationAnimation = TweenSequence(<TweenSequenceItem>[
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController!);

    degTwoTranslationAnimation = TweenSequence(<TweenSequenceItem>[
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0)
    ]).animate(animationController!);

    degThreeTranslationAnimation = TweenSequence(<TweenSequenceItem>[
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0)
    ]).animate(animationController!);

    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController!, curve: Curves.easeOut));

    super.initState();

    animationController!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: <Widget>[
          Transform.translate(
            offset: Offset.fromDirection(getRadiansFromDegree(90),
                degOneTranslationAnimation!.value * 80),
            child: Transform(
              transform: Matrix4.rotationZ(
                  getRadiansFromDegree(rotationAnimation!.value))
                ..scale(degOneTranslationAnimation!.value),
              alignment: Alignment.center,
              child: _circularButton(
                width: 50,
                height: 50,
                bgColor: Colors.white,
                icon: const Icon(
                  Icons.location_pin,
                  color: Color(0xff1d3f46),
                ),
                onClick: widget.locationOnPressed,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset.fromDirection(getRadiansFromDegree(90),
                degOneTranslationAnimation!.value * 140),
            child: Transform(
              transform: Matrix4.rotationZ(
                  getRadiansFromDegree(rotationAnimation!.value))
                ..scale(degOneTranslationAnimation!.value),
              alignment: Alignment.center,
              child: _circularButton(
                width: 50,
                height: 50,
                bgColor: Colors.white,
                icon: const Icon(
                  Icons.location_city,
                  color: Color(0xff1d3f46),
                ),
                onClick: widget.cityOnPressed,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset.fromDirection(getRadiansFromDegree(90),
                degOneTranslationAnimation!.value * 200),
            child: Transform(
              transform: Matrix4.rotationZ(
                  getRadiansFromDegree(rotationAnimation!.value))
                ..scale(degOneTranslationAnimation!.value),
              alignment: Alignment.center,
              child: _circularButton(
                width: 50,
                height: 50,
                bgColor: Colors.white,
                icon: const Icon(
                  Icons.map_sharp,
                  color: Color(0xff1d3f46),
                ),
                onClick: widget.mapOnPressed,
              ),
            ),
          ),
          Transform(
            transform: Matrix4.rotationZ(
                getRadiansFromDegree(rotationAnimation!.value)),
            alignment: Alignment.center,
            child: _circularButton(
              width: 60,
              height: 60,
              icon: const Icon(
                Icons.list_alt,
                color: Colors.white,
              ),
              onClick: () {
                if (animationController!.isCompleted) {
                  animationController!.reverse();
                } else {
                  animationController!.forward();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularButton(
      {Color? bgColor,
      required double width,
      required double height,
      required Icon icon,
      required VoidCallback onClick}) {
    return Container(
      decoration: BoxDecoration(
          color: bgColor ?? const Color(0x661d3f46), shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon, onPressed: onClick),
    );
  }
}
