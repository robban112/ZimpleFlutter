import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class SimpleLogPrinter extends LogPrinter {
  final String className;
  SimpleLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    return [""];
    // var color = PrettyPrinter.levelColors[level];
    // var emoji = PrettyPrinter.levelEmojis[level];
    // println(color('$emoji $className - $message'));
  }
}
