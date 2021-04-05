import 'package:flutter/material.dart';

class VerticalTimeContainer extends StatelessWidget {
  final double width;
  final double minuteHeight;

  VerticalTimeContainer({this.width, this.minuteHeight});

  String _getTime(int index) {
    var hour;
    if (index < 10) {
      hour = '0' + index.toString() + ':00';
    } else {
      hour = index.toString() + ':00';
    }
    return hour;
  }

  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: List.generate(24, (index) {
          return index == 0
              ? SizedBox(
                  height: minuteHeight * 46,
                  width: width,
                )
              : Container(
                  height: minuteHeight * 60,
                  child: Text(
                    _getTime(index),
                    style: const TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.black),
                  ),
                );
        }),
      ),
    );
  }
}
