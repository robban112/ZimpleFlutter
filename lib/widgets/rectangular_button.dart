import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RectangularButton extends StatelessWidget {
  final Function onTap;
  final String text;
  final EdgeInsets padding;
  final Color? color;
  final Color? textColor;
  RectangularButton({
    required this.onTap,
    required this.text,
    this.color,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: padding,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      child: ButtonTheme(
        height: 60,
        child: ElevatedButton(
          child: Text(text, style: TextStyle(fontSize: 17.0, color: textColor ?? Colors.white)),
          onPressed: () {
            HapticFeedback.lightImpact();
            this.onTap();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: color ?? Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
