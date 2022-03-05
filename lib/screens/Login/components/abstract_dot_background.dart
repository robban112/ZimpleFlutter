import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';

class AbstractDotBackground extends StatelessWidget {
  static const double dotSize = 5;

  static const double spacing = 25.0;

  static const double minDotSize = 2;

  final double? overrideHeight;

  final double? overrideWidth;

  const AbstractDotBackground({
    Key? key,
    this.overrideHeight,
    this.overrideWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: _buildDots(context),
    );
  }

  int numDotsHorizontal(double width, double spacing) {
    return (width + spacing) ~/ (minDotSize + spacing);
  }

  int numDotsVertical(double height, double spacing) {
    return (height + spacing) ~/ (minDotSize + spacing);
  }

  Widget _buildDots(BuildContext context) {
    int _numDotsVertical = numDotsVertical(overrideHeight ?? height(context), spacing);
    int _numDotsHorizontal = numDotsHorizontal(overrideWidth ?? width(context), spacing);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(
        _numDotsVertical,
        (vIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
              _numDotsHorizontal,
              (hIndex) => Dot(),
            ),
          );
        },
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = ThemeNotifier.of(context).textColor;
    double randomOpacity = 0.05 + Random().nextInt(10) / 100;
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      height: 2,
      width: 2,
      decoration: BoxDecoration(
        color: color.withOpacity(randomOpacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
