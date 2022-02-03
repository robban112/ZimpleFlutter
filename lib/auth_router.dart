import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/login_screen.dart';
import 'package:zimple/screens/tab_bar_widget.dart';

class AuthRouter extends StatelessWidget {
  final User? user;
  const AuthRouter({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return user != null ? TabBarWidget() : LoginScreen();
  }
}
