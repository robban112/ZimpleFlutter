import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ZCloseButton extends StatelessWidget {
  final Color? color;
  const ZCloseButton({
    Key? key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => Navigator.of(context).pop(),
      child: Container(
        margin: EdgeInsets.all(16),
        height: 54,
        width: 54,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SvgPicture.asset('images/exit.svg', color: color ?? Colors.white),
        )),
      ),
    );
  }
}
