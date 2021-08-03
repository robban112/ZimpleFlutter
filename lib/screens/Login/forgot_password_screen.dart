import 'package:flutter/material.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import '../../utils/constants.dart';
import 'package:zimple/utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static final routeName = "forgot_password_screen";

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  String _email = "";
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool hasSentEmail = false;

  void _sendVerificationEmail() {
    if (hasSentEmail) {
      return;
    }
    setState(() {
      _autoValidateMode = AutovalidateMode.always;
    });
    if (emailValidator(_email) == null) {
      setState(() {
        hasSentEmail = true;
      });
      //FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text("Glömt lösenord"),
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 190),
              AnimatedContainer(
                height: hasSentEmail ? 0 : 35,
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 200),
                child: Text(
                  "Skriv in din email så skickar vi ett mail med instruktioner för att återställa ditt lösenord.",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              AnimatedContainer(
                  height: hasSentEmail ? 0 : 52,
                  curve: Curves.bounceIn,
                  duration: Duration(milliseconds: 200),
                  child: hasSentEmail ? Container() : buildEmailFormField()),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: kPadding),
                child: RectangularButton(
                  onTap: _sendVerificationEmail,
                  text: hasSentEmail ? "Skickat! Kolla din mail" : "Skicka",
                ),
              )
            ],
          ),
        ));
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      key: _emailFormKey,
      validator: emailValidator,
      autovalidateMode: _autoValidateMode,
      onChanged: (value) {
        setState(() {
          _email = value;
        });
        //Do something with the user input.
      },
      style: TextStyle(color: Colors.white, fontSize: 17.0),
      autocorrect: false,
      decoration: textFieldInputDecoration.copyWith(
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        hintText: 'EMAIL',
        hintStyle: TextStyle(color: Colors.grey.shade100, fontSize: 14.0),
        prefixIcon: Icon(
          Icons.email,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
