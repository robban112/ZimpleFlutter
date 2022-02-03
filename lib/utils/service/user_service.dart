import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserService extends ChangeNotifier {
  User? user;

  UserService(this.user);

  static UserService of(BuildContext context) => context.read<UserService>();
}
