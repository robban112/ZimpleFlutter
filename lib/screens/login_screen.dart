import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../widgets/authentication_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Calendar/calendar_screen.dart';
import 'tab_bar_controller.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  void loginUser(String email, String password) async {
    setLoading(true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      setLoading(false);
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (BuildContext context) => CalendarScreen()));
      Navigator.pushNamedAndRemoveUntil(
          context, TabBarController.routeName, (route) => false);
    } catch (e) {
      setLoading(false);
      print(e);
    }
  }

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 150.0),
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 30.0,
                      child: Image.asset('images/zimple_logo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  AuthenticationForm(
                    loginRegisterText: 'Logga in',
                    onTapLoginRegister: loginUser,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
