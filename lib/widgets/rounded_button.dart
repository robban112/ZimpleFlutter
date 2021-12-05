import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function? onTap;
  final double minWidth;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  RoundedButton(
      {this.text = "",
      this.color = Colors.green,
      this.onTap,
      this.minWidth = 20,
      this.textColor = Colors.black,
      this.fontSize = 14,
      this.padding = const EdgeInsets.all(8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      height: 55.0,
      child: ButtonTheme(
        height: 60.0,
        child: ElevatedButton(
          child: Text(this.text, style: TextStyle(fontSize: fontSize, color: Colors.black)),
          onPressed: () {
            if (this.onTap == null) return;
            HapticFeedback.lightImpact();
            this.onTap!();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100.0, 50.0),
            elevation: 5,
            primary: this.color,
            onPrimary: this.textColor == null ? Colors.white : this.textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }
}
