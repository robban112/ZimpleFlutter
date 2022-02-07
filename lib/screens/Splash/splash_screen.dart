import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:zimple/screens/Login/components/abstract_wave_animation.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback finishedSplash;
  const SplashScreen({Key? key, required this.finishedSplash}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late RiveAnimationController _animationController;

  @override
  void initState() {
    _animationController = SimpleAnimation('Animation 1', autoplay: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          ZimpleDotBackground(),
          Center(
            child: Container(
              height: 250,
              width: 250,
              child: RiveAnimation.asset(
                'assets/rives/zimplesplash.riv',
                controllers: [
                  _animationController,
                ],
              ),
            ),
          ),
          Lines(
            onFinishAnimation: () {
              _animationController.isActive = true;
              Future.delayed(Duration(milliseconds: 1350), () {
                widget.finishedSplash();
              });
            },
          ),
        ],
      ),
    ));
  }
}

class Lines extends StatefulWidget {
  final VoidCallback onFinishAnimation;
  Lines({required this.onFinishAnimation});
  @override
  _LinesState createState() => _LinesState();
}

class _LinesState extends State<Lines> with TickerProviderStateMixin {
  bool showDots = false, showPath = true;
  late AnimationController _controller;
  late AnimationController _secondController;

  late Animation<Offset> _first;

  late Animation<Offset> _second;

  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _secondController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _secondController.forward();
    });

    _secondController.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onFinishAnimation();
    });

    _first = Tween<Offset>(begin: Offset(0.01, 0), end: Offset(1, 0)).animate(
      CurvedAnimation(parent: _secondController, curve: Curves.ease),
    );

    _second = Tween<Offset>(begin: Offset(-0.01, 0), end: Offset(-1, 0)).animate(
      CurvedAnimation(parent: _secondController, curve: Curves.ease),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );

    Future.delayed(Duration.zero, () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
            animation: _secondController,
            builder: (context, child) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Expanded(
                    child: Center(
                      child: Stack(
                        children: [
                          CustomPaint(
                            painter: LinePainter(
                              progress: _progressAnimation.value,
                              screenSize: MediaQuery.of(context).size,
                              offset: _first.value,
                            ),
                          ),
                          CustomPaint(
                            painter: LinePainter(
                              progress: _progressAnimation.value,
                              screenSize: MediaQuery.of(context).size,
                              offset: _second.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LinePainter extends CustomPainter {
  LinePainter({
    required this.progress,
    required this.screenSize,
    required this.offset,
  });
  final double progress;
  final Size screenSize;
  final Offset offset;
  Paint _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(screenSize.width * offset.dx, screenSize.height / 2);
    final p2 = Offset(screenSize.width * offset.dx, -2 * screenSize.height / 2 * progress + screenSize.height / 2);
    canvas.drawLine(p1, p2, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SpiralPainter extends CustomPainter {
  SpiralPainter({
    required this.progress,
    required this.showPath,
    required this.showDots,
  });

  final double progress;
  bool showDots, showPath;

  Paint _paint = Paint()
    ..color = Colors.white
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = createSpiralPath(size);
    PathMetric pathMetric = path.computeMetrics().first;
    Path extractPath = pathMetric.extractPath(0.0, pathMetric.length * progress);
    if (showPath) {
      canvas.drawPath(extractPath, _paint);
    }
    if (showDots) {
      try {
        var metric = extractPath.computeMetrics().first;
        final offset = metric.getTangentForOffset(metric.length)!.position;
        canvas.drawCircle(offset, 8.0, Paint());
      } catch (e) {}
    }
  }

  Path createSpiralPath(Size size) {
    double radius = 0, angle = 0;
    Path path = Path();
    for (int n = 0; n < 200; n++) {
      radius += 0.75;
      angle += (math.pi * 2) / 50;
      var x = size.width / 2 + radius * math.cos(angle);
      var y = size.height / 2 + radius * math.sin(angle);
      path.lineTo(x, y);
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
