import 'package:flutter/material.dart';

class ZimpleDotBackground extends StatefulWidget {
  final GlobalKey<ZimpleDotBackgroundState>? waveKey;

  final bool shouldAnimate;

  final Color? overrideColor;

  const ZimpleDotBackground({
    this.waveKey,
    this.shouldAnimate = true,
    this.overrideColor,
  }) : super(key: waveKey);

  @override
  ZimpleDotBackgroundState createState() => ZimpleDotBackgroundState();
}

class ZimpleDotBackgroundState extends State<ZimpleDotBackground> {
  static const double dotSize = 5;

  static const double spacing = 25.0;

  static const double minDotSize = 2;

  List<List<AnimatingDotModel>> _dots = [];

  bool hasLoadedDots = false;

  late int _numDotsHorizontal;

  late int _numDotsVertical;

  static const Duration animationDuration = Duration(milliseconds: 2000);

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;

      this._numDotsHorizontal = numDotsHorizontal(width, spacing);
      this._numDotsVertical = numDotsVertical(height, spacing);

      print("numDotsHorizontal: $_numDotsHorizontal");
      print("numDotsVertical: $_numDotsVertical");
      List<List<AnimatingDotModel>> cols = [];
      for (int vertical = 0; vertical < _numDotsVertical; vertical++) {
        List<AnimatingDotModel> rows = [];
        for (int horizontal = 0; horizontal < _numDotsHorizontal; horizontal++) {
          AnimatingDotModel model = AnimatingDotModel(GlobalKey<_AnimatingDotState>(), MatrixIndex(vertical, horizontal));
          rows.add(model);
        }
        cols.add(rows);
      }

      setState(() {
        hasLoadedDots = true;
        _dots = cols;
      });

      // Future.delayed(Duration(milliseconds: 300), () {
      //   animateWave();
      // });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: _buildDots(),
      ),
    );
  }

  int numDotsHorizontal(double width, double spacing) {
    return (width + spacing) ~/ (minDotSize + spacing);
  }

  int numDotsVertical(double height, double spacing) {
    return (height + spacing) ~/ (minDotSize + spacing);
  }

  Widget _buildDots() {
    if (!hasLoadedDots) return Container();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List<Widget>.generate(
        _dots.length,
        (vIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
              _dots[vIndex].length,
              (hIndex) => AnimatingDot(
                shouldAnimate: widget.shouldAnimate,
                minDotSize: minDotSize,
                spacingAndDotSize: dotSize + spacing,
                animateKey: _dots[vIndex][hIndex].key,
                dotSize: dotSize,
                index: hIndex,
                animationDuration: animationDuration,
                overrideColor: widget.overrideColor,
              ),
            ),
          );
        },
      ),
    );
  }

  void animateWave() {
    for (int i = 0; i < _numDotsVertical; i++) {
      var models = getIndexed(i);
      models.forEach((model) {
        model.globalKey.currentState?.animate(withDelay: i * 10);
      });
    }
  }

  List<AnimatingDotModel> getIndexed(int i) {
    List<AnimatingDotModel> models = [];

    for (int a = 0; a < i; a++) {
      if (_dots[0].length > a) {
        models.add(_dots[i][a]);
      }
      if (_dots.length > a && _dots.first.length > i) {
        models.add(_dots[a][i]);
      }
    }
    return models;
  }

  void onTapDown(TapDownDetails details) {
    double dx = details.globalPosition.dx;
    double dy = details.globalPosition.dy;

    int vIndex = ((dx / MediaQuery.of(context).size.width) * _numDotsHorizontal).toInt();
    int hIndex = (((dy / MediaQuery.of(context).size.height) * _numDotsVertical)).toInt();

    print("index: v$vIndex, h$hIndex, dy: $dy, dx: $dx");
    //_handleAnimateDot(_dots[hIndex][vIndex]);
    animateWave();
  }

  int iteration = 0;

  void _handleAnimateDot(AnimatingDotModel model) {
    if (iteration > 1000) return;
    model.globalKey.currentState?.animate();

    List<MatrixIndex> neighbourIndexes = model.getNeighbours(_numDotsHorizontal, _numDotsVertical);
    print("neighbours: ${neighbourIndexes.map((e) => "[${e.x}, ${e.y}]")}");
    List<AnimatingDotModel> neighbours = [];
    neighbourIndexes.forEach((index) {
      AnimatingDotModel otherModel = _dots[index.x][index.y];
      if (!otherModel.isAnimating) neighbours.add(otherModel);
    });

    Future.delayed(Duration(milliseconds: 260), () {
      iteration++;
      neighbours.forEach((model) => _handleAnimateDot(model));
    });
  }
}

class AnimatingDot extends StatefulWidget {
  final GlobalKey<_AnimatingDotState> animateKey;
  final int index;
  final double dotSize;
  final double spacingAndDotSize;
  final double minDotSize;
  final Duration animationDuration;
  final bool shouldAnimate;
  final Color? overrideColor;
  const AnimatingDot({
    required this.index,
    required this.dotSize,
    required this.animateKey,
    required this.spacingAndDotSize,
    required this.minDotSize,
    required this.animationDuration,
    required this.shouldAnimate,
    this.overrideColor,
  }) : super(key: animateKey);

  @override
  State<AnimatingDot> createState() => _AnimatingDotState();
}

class _AnimatingDotState extends State<AnimatingDot> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: widget.animationDuration);

  late final Animation<double> sizeAnimation;

  @override
  void initState() {
    sizeAnimation = Tween<double>(begin: widget.minDotSize, end: widget.dotSize)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn))
      ..addListener(() => setState(() => {}));
    // ..addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     controller.reverse();
    //   }
    // });
    if (widget.shouldAnimate) {
      Future.delayed(Duration(milliseconds: 100 * widget.index), () {
        controller.repeat(reverse: true);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void animate({int? withDelay}) {
    if (withDelay != null) {
      Future.delayed(Duration(milliseconds: withDelay), () {
        controller.forward();
      });
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sizeAnimation,
      builder: (context, _) => SizedBox(
        height: sizeAnimation.value,
        width: sizeAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.01 * (sizeAnimation.value / widget.dotSize) + 0.12),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Color get color => widget.overrideColor ?? Colors.white;
}

class Position {
  final double x;
  final double y;
  Position(this.x, this.y);
}

class MatrixIndex {
  final int x;
  final int y;
  MatrixIndex(this.x, this.y);
}

class AnimatingDotModel {
  bool isAnimating = false;

  final GlobalKey<_AnimatingDotState> key;

  GlobalKey<_AnimatingDotState> get globalKey => key;

  //final Position position;

  final MatrixIndex index;

  AnimatingDotModel(
    this.key,
    //this.position,
    this.index,
  );

  bool isWithinBoundaries(Position pos) {
    return false;
  }

  List<MatrixIndex> getNeighbours(int maxY, int maxX) {
    int x = index.x;
    int y = index.y;
    List<MatrixIndex> indexes = [];
    if (x > 0) {
      indexes.add(MatrixIndex(x - 1, y));
    }

    if (x < maxX) {
      indexes.add(MatrixIndex(x + 1, y));
    }

    if (y > 0) {
      indexes.add(MatrixIndex(x, y - 1));
    }

    if (y < maxY) {
      indexes.add(MatrixIndex(x, y + 1));
    }

    return indexes;
  }
}
