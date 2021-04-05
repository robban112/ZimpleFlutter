import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function onTap;
  final double minWidth;
  final Color textColor;
  final double fontSize;
  RoundedButton(
      {this.text,
      this.color,
      this.onTap,
      this.minWidth,
      this.textColor,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.0,
      child: ButtonTheme(
        height: 60.0,
        child: ElevatedButton(
          child: Text(this.text,
              style: TextStyle(fontSize: fontSize == null ? 21.0 : fontSize)),
          onPressed: () {
            this.onTap();
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
