import 'package:flutter/material.dart';
import 'package:zimple/utils/color_utils.dart';

class Person {
  String name;
  Color color;
  String id;
  String? email;
  String? profilePicturePath;
  String? phonenumber;
  String? iOSLink;
  String? androidLink;
  String? ssn;
  String? address;

  Person({
    required this.name,
    required this.color,
    required this.id,
    this.email,
    this.profilePicturePath,
    this.phonenumber,
    this.iOSLink,
    this.androidLink,
    this.ssn,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'email': this.email,
        'phonenumber': this.phonenumber,
        'id': this.id,
        'color': colorToString(this.color),
        'iOSLink': this.iOSLink,
        'androidLink': this.androidLink,
        'ssn': this.ssn,
        'address': this.address,
      };
}
