import 'package:flutter/material.dart';

class Person {
  String name;
  Color color;
  String id;
  String email;

  Person(
      {@required this.name,
      @required this.color,
      @required this.id,
      this.email});
}
