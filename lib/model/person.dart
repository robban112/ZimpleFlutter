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
  final String? salary;

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
    this.salary,
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
        'salary': this.salary,
      };

  static Person fromJson(dynamic personData, {required String key}) {
    return Person(
      color: hexToColor(personData['color']),
      name: personData['name'] ?? "",
      id: key,
      email: personData['email'],
      profilePicturePath: personData['profilePicturePath'],
      phonenumber: personData['phonenumber'],
      iOSLink: personData['iOSLink'],
      androidLink: personData['androidLink'],
      ssn: personData['ssn'],
      address: personData['address'],
      salary: personData['salary'],
    );
  }
}
