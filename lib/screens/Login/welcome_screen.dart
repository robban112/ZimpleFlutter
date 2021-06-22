import 'package:flutter/material.dart';

import 'login_screen.dart';
//import 'registration_screen.dart';
import '../../widgets/rounded_button.dart';
import 'package:zimple/utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    animation =
        CurvedAnimation(parent: animationController, curve: Curves.decelerate);
    animationController.forward();

    animationController.addListener(() {
      setState(() {});
      animation.value;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset(
                      'images/zimple_logo.png',
                    ),
                    height: animation.value * 40,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 100.0,
            ),
            Hero(
              tag: 'login_button',
              child: RoundedButton(
                text: 'Logga in',
                color: Colors.lightBlue,
                textColor: Colors.white,
                onTap: () {
                  Navigator.pushNamed(context, LoginScreen.routeName);
                },
              ),
            ),
            // Hero(
            //   tag: 'register_button',
            //   child: RoundedButton(
            //     text: 'Register',
            //     color: Colors.white,
            //     onTap: () {
            //       //Navigator.pushNamed(context, RegistrationScreen.routeName);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
