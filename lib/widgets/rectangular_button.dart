import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';

class RectangularButton extends StatelessWidget {
  final Function onTap;
  final String text;
  RectangularButton({required this.onTap, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      child: ButtonTheme(
        height: 60,
        child: ElevatedButton(
          child: Text(text, style: TextStyle(fontSize: 17.0, color: Colors.white)),
          onPressed: () {
            this.onTap();
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
