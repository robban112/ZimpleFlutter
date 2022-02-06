import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';

class ZTextfield extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final String? Function(String?)? validator;

  final AutovalidateMode? autoValidateMode;

  final TextEditingController controller;

  final String hintText;

  final Widget prefixIcon;

  final TextInputType inputType;

  final FocusNode focusNode;

  final bool obscureText;

  ZTextfield({
    Key? key,
    required this.formKey,
    required this.validator,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.inputType,
    required this.focusNode,
    this.obscureText = false,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildEmailFormField();
  }

  Widget buildEmailFormField() {
    return TextFormField(
      key: formKey,
      validator: validator,
      autovalidateMode: autoValidateMode,
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: 17.0),
      autocorrect: false,
      focusNode: focusNode,
      keyboardType: inputType,
      textInputAction: TextInputAction.done,
      obscureText: obscureText,
      decoration: textFieldInputDecoration.copyWith(
        contentPadding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 15.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade100, fontSize: 14.0),
        prefixIcon: prefixIcon,
      ),
    );
  }
}
