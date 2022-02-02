import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/screens/Login/Signup/sign_up_screen.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:zimple/utils/constants.dart';
import '../../widgets/authentication_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../tab_bar_widget.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  bool _errorLogin = false;
  final double kPadding = 24.0;

  void loginUser(String email, String password) async {
    context.loaderOverlay.show();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      context.loaderOverlay.hide();
      Navigator.pushNamedAndRemoveUntil(context, TabBarWidget.routeName, (route) => false);
    } catch (e) {
      context.loaderOverlay.hide();
      setState(() {
        this._errorLogin = true;
      });
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
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: primaryColor,
      body: LoaderOverlay(
        overlayWidget: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(green),
        ),
        overlayOpacity: 0.5,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: _loginBody(context),
          ),
        ),
      ),
    );
  }

  Widget _createAccount() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(CupertinoPageRoute(builder: (_) => SignUpScreen()));
            },
            child: Text(
              "Skapa konto >>",
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align _loginBody(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(height: 50, color: primaryColor),
                    Container(
                      height: 180,
                    ),
                    SizedBox(height: 12),
                    _logo(),
                  ],
                ),
                SizedBox(
                  height: 48.0,
                ),
                AuthenticationForm(
                  loginRegisterText: 'Logga in',
                  onTapLoginRegister: loginUser,
                  hasError: this._errorLogin,
                ),
                SizedBox(height: 5.0),
                _forgotPassword(context),
              ],
            ),
          ),
          SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _createAccount(),
                ],
              ))
        ],
      ),
    );
  }

  Padding _forgotPassword(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: TextButton(
        child: Text("Glömt ditt lösenord?", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
        },
      ),
    );
  }

  Container _logo() {
    return Container(
      height: 50,
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
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(200), bottomRight: Radius.circular(200))),
    );
  }
}
