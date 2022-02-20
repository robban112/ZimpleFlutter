import 'package:flutter/material.dart';
import 'package:zimple/utils/color_utils.dart';

class Person {
  final String name;
  final Color color;
  final String id;
  final String? email;
  final String? profilePicturePath;
  final String? phonenumber;
  final String? iOSLink;
  final String? androidLink;
  final String? ssn;
  final String? address;

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
        'profilePicturePath': this.profilePicturePath,
      };
}
