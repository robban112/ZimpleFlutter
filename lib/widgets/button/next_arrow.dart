import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NextArrow extends StatelessWidget {
  final Color? color;
  const NextArrow({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: pi,
      child: SizedBox(
        height: 14,
        width: 14,
        child: SvgPicture.asset(
          'images/arrow_back.svg',
          color: color ?? Theme.of(context).iconTheme.color!,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
