import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/screens/Login/Signup/sign_up_screen.dart';
import 'package:zimple/screens/Login/components/abstract_wave_animation.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:zimple/utils/constants.dart';

import '../../widgets/authentication_form.dart';
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

  GlobalKey<ZimpleDotBackgroundState> abstractWaveKey = GlobalKey<ZimpleDotBackgroundState>();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: LoaderOverlay(
        overlayWidgetBuilder: (_) => CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(green),
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          //onTapDown: abstractWaveKey.currentState?.onTapDown,
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
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(builder: (_) => SignUpScreen()));
            },
            child: Container(
              width: 160,
              height: 50,
              child: Center(
                child: Text(
                  "Skapa konto >>",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FiraSans',
                  ),
                ),
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
      child: Stack(
        children: [
          _background(context),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _logo(),
                      SizedBox(height: 48.0),
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
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: _createAccount(),
                    ),
                  ],
                ),
              )
            ],
          ),
          Align(alignment: Alignment.bottomCenter, child: _createAccount()),
        ],
      ),
    );
  }

  Widget _background(BuildContext context) {
    return ZimpleDotBackground(waveKey: abstractWaveKey);
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
        padding: EdgeInsets.symmetric(horizontal: kPadding * 2.5),
        child: Hero(
          tag: 'logo',
          child: Container(
            height: 45.0,
            child: SvgPicture.asset('images/zimple_logo_white.svg'),
          ),
        ),
      ),
    );
  }

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
}
