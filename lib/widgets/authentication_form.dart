import 'package:flutter/material.dart';
import 'rounded_button.dart';
import '../utils/constants.dart';
//import 'package:flash_chat/constants.dart';

class AuthenticationForm extends StatefulWidget {
  Function(String, String) onTapLoginRegister;
  final String loginRegisterText;
  AuthenticationForm(
      {@required this.loginRegisterText, this.onTapLoginRegister});
  @override
  _AuthenticationFormFieldState createState() =>
      _AuthenticationFormFieldState();
}

class _AuthenticationFormFieldState extends State<AuthenticationForm> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _email;
  String _password;

  String passwordValidator(String pass) {
    return pass.length < 4 ? '*Required' : null;
  }

  bool validateLoginInput() {
    setState(() {
      _autoValidate = true;
    });
    print(emailValidator(_email));
    print(passwordValidator(_password));
    return (emailValidator(_email) == null &&
        passwordValidator(_password) == null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          key: _emailFormKey,
          validator: emailValidator,
          autovalidate: _autoValidate,
          onChanged: (value) {
            setState(() {
              _email = value;
            });
            //Do something with the user input.
          },
          style: TextStyle(color: Colors.white, fontSize: 17.0),
          autocorrect: false,
          decoration: textFieldInputDecoration.copyWith(
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
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
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          key: _passwordFormKey,
          validator: passwordValidator,
          keyboardType: TextInputType.visiblePassword,
          autovalidate: _autoValidate,
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _password = value;
            });
            //Do something with the user input.
          },
          obscureText: true,
          decoration: textFieldInputDecoration.copyWith(
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            hintText: 'PASSWORD',
            hintStyle: TextStyle(color: Colors.white, fontSize: 14.0),
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        SizedBox(
          height: 24.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Hero(
            tag: 'register_button',
            child: RoundedButton(
              color: Colors.lightBlue,
              text: widget.loginRegisterText,
              textColor: Colors.white,
              onTap: () {
                if (validateLoginInput()) {
                  widget.onTapLoginRegister(_email, _password);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
