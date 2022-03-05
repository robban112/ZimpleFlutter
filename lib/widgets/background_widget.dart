import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/components/abstract_dot_background.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  const BackgroundWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AbstractDotBackground(),
        ),
        child,
      ],
    );
  }
}
