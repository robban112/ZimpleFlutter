import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:zimple/utils/constants.dart';
import '../../widgets/authentication_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../tab_bar_controller.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final double kPadding = 24.0;

  void loginUser(String email, String password) async {
    setLoading(true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      setLoading(false);
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
      backgroundColor: primaryColor,
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: green,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(height: 100, color: primaryColor),
                    Container(
                      height: 150,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: kPadding * 3),
                        child: Hero(
                          tag: 'logo',
                          child: Container(
                            height: 30.0,
                            child: Image.asset('images/zimple_logo.png'),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(200),
                              bottomRight: Radius.circular(200))),
                    ),
                  ],
                ),
                SizedBox(
                  height: 48.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: kPadding),
                  child: AuthenticationForm(
                    loginRegisterText: 'Logga in',
                    onTapLoginRegister: loginUser,
                  ),
                ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: TextButton(
                    child: Text("Glöm ditt lösenord?",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, ForgotPasswordScreen.routeName);
                    },
                  ),
                ),
                SizedBox(height: 35.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
