import 'package:flutter/material.dart';

Color hexToColor(String hexString, {String alphaChannel = 'F0'}) {
  return Color(int.parse(alphaChannel + hexString, radix: 16));
}

int toHex(String hexString) {
  int.parse(hexString, radix: 16);
}
