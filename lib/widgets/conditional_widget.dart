import 'package:flutter/material.dart';

class ConditionalWidget extends StatelessWidget {
  final Widget childTrue;
  final Widget childFalse;
  final bool condition;
  ConditionalWidget({this.condition, this.childTrue, this.childFalse});
  @override
  Widget build(BuildContext context) {
    return condition ? childTrue : childFalse;
  }
}
