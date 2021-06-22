import 'package:flutter/material.dart';

class Person {
  String name;
  Color color;
  String id;
  String? email;
  String? profilePicturePath;
  String? phonenumber;

  Person(
      {required this.name,
      required this.color,
      required this.id,
      this.email,
      this.profilePicturePath,
      this.phonenumber});
}
