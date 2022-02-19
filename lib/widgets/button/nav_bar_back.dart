import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavBarBack extends StatelessWidget {
  final VoidCallback? onPressed;

  const NavBarBack({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed != null ? () => onPressed!() : () => Navigator.of(context).pop(),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: SvgPicture.asset(
                'images/arrow_back.svg',
                color: Colors.white,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
