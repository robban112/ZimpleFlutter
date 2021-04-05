import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import './login_screen.dart';
import '../model/destination.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = "settings_screen";

  const SettingsScreen();

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void onPressed(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    pushNewScreenWithRouteSettings(
      context,
      settings: RouteSettings(name: LoginScreen.routeName),
      screen: LoginScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            child: Icon(
              Icons.person,
              size: 50,
            ),
            radius: 75,
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Material(
              elevation: 18.0,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                ),
                height: 50,
                minWidth: 150,
                color: Colors.red.shade400,
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Center(
                  child: Text(
                    "Logga ut",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ),
                onPressed: () => onPressed(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
