import 'package:flutter/material.dart';
import 'package:zimple/utils/color_utils.dart';

class Person {
  String name;
  Color color;
  String id;
  String? email;
  String? profilePicturePath;
  String? phonenumber;

  Person({required this.name, required this.color, required this.id, this.email, this.profilePicturePath, this.phonenumber});

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'email': this.email,
        'phonenumber': this.phonenumber,
        'id': this.id,
        'color': colorToString(this.color),
      };
}
