import 'package:flutter/material.dart';
import 'package:zimple/widgets/rectangular_button.dart';

import '../utils/constants.dart';
//import 'package:flash_chat/constants.dart';

class AuthenticationForm extends StatefulWidget {
  final Function(String, String) onTapLoginRegister;
  final String loginRegisterText;
  final bool? hasError;
  AuthenticationForm({required this.loginRegisterText, required this.onTapLoginRegister, this.hasError});
  @override
  _AuthenticationFormFieldState createState() => _AuthenticationFormFieldState();
}

class _AuthenticationFormFieldState extends State<AuthenticationForm> {
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  late String _email;
  late String _password;

  bool validateLoginInput() {
    setState(() {
      _autoValidate = true;
    });
    return (emailValidator(_email) == null && passwordValidator(_password) == null);
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
        _emailPassTextFields(),
        _forgotPassword(),
        SizedBox(height: 24.0),
        _loginButton(),
      ],
    );
  }

  AnimatedContainer _forgotPassword() {
    return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: (widget.hasError ?? false) ? 30 : 0,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("Fel lösenord", style: TextStyle(color: Colors.red, fontSize: 17)),
          ),
        ));
  }

  Widget _emailPassTextFields() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kPadding),
      child: Column(
        children: [
          TextFormField(
            key: _emailFormKey,
            validator: emailValidator,
            autovalidateMode: _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
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
            autovalidateMode: (_autoValidate || (widget.hasError ?? false)) ? AutovalidateMode.always : AutovalidateMode.disabled,
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _password = value;
              });
              //Do something with the user input.
            },
            obscureText: true,
            decoration: _textfieldDecoration(Icons.lock, 'LÖSENORD'),
          ),
        ],
      ),
    );
  }

  Padding _loginButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Hero(
        tag: 'register_button',
        child: RectangularButton(
          padding: EdgeInsets.symmetric(horizontal: kPadding),
          text: widget.loginRegisterText,
          onTap: () {
            if (validateLoginInput()) {
              widget.onTapLoginRegister(_email, _password);
            }
          },
        ),
      ),
    );
  }
}
