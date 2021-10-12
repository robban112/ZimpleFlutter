import 'package:flutter/material.dart';

Color hexToColor(String hexString, {String alphaChannel = 'F0'}) {
  return Color(int.parse(alphaChannel + hexString, radix: 16));
}

String colorToString(Color color) {
  return '${color.value.toRadixString(16).substring(2, 8)}';
}

int toHex(String hexString) {
  return int.parse(hexString, radix: 16);
}

Color dynamicBlackWhite(Color color) {
  return color.computeLuminance() < 0.5 ? Colors.white : Colors.black;
}
