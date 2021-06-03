import 'package:flutter/material.dart';

class UserParameters {
  String email;
  String token;
  String company;
  String name;
  bool isAdmin;
  String profilePicturePath;

  UserParameters(
      {@required this.email,
      @required this.token,
      @required this.company,
      @required this.isAdmin,
      this.name,
      this.profilePicturePath});
}
