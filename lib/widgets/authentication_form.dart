import 'package:flutter/material.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import 'rounded_button.dart';
import '../utils/constants.dart';
//import 'package:flash_chat/constants.dart';

class AuthenticationForm extends StatefulWidget {
  Function(String, String) onTapLoginRegister;
  final String loginRegisterText;
  AuthenticationForm(
      {required this.loginRegisterText, required this.onTapLoginRegister});
  @override
  _AuthenticationFormFieldState createState() =>
      _AuthenticationFormFieldState();
}

class _AuthenticationFormFieldState extends State<AuthenticationForm> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  late String _email;
  late String _password;

  String? passwordValidator(String? pass) {
    if (pass == null) return null;
    return pass.length < 4 ? '*Required' : null;
  }

  bool validateLoginInput() {
    setState(() {
      _autoValidate = true;
    });
    return (emailValidator(_email) == null &&
        passwordValidator(_password) == null);
  }

  InputDecoration _textfieldDecoration(IconData leadingIcon, String hintText) {
    return textFieldInputDecoration.copyWith(
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(
          color: Colors.white,
        ),
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white, fontSize: 14.0),
      prefixIcon: Icon(
        leadingIcon,
        color: Colors.grey.shade300,
      ),
    );
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
          decoration: _textfieldDecoration(Icons.email, 'EMAIL'),
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
          decoration: _textfieldDecoration(Icons.lock, 'PASSWORD'),
        ),
        SizedBox(
          height: 24.0,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          child: Hero(
            tag: 'register_button',
            child: RectangularButton(
              text: widget.loginRegisterText,
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
