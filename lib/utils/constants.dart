import 'package:flutter/material.dart';

const locale = 'sv_SE';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const textFieldInputDecoration = InputDecoration(
  hintStyle: TextStyle(
      color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 14.0),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(25.0),
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black38, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(25.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(25.0)),
  ),
);

final double kPadding = 24.0;
final TextStyle greyText = TextStyle(
  color: Colors.grey[500],
  fontSize: 14.0,
);

final Color shadedGrey = Color(0xffF5F6F9);
final Color primaryColor = Color(0xff303E52);
//final Color primaryColor = Colors.black;
final Color backgroundColor = Color(0xffF7FAFB);
final Color green = Color(0xff7BC9B5);

final List<BoxShadow> standardShadow = [
  BoxShadow(
    color: Colors.grey.withOpacity(0.12),
    spreadRadius: 1,
    blurRadius: 3,
    offset: Offset(-2, 2), // changes position of shadow
  )
];

String? emailValidator(String? value) {
  if (value == null) return null;
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern.toString());
  if (value.isEmpty) return '*Required';
  if (!regex.hasMatch(value))
    return '*Enter a valid email';
  else
    return null;
}
