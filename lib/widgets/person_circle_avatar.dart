import 'package:flutter/material.dart';
import 'package:zimple/model/person.dart';

class PersonCircleAvatar extends StatelessWidget {
  final Person person;
  PersonCircleAvatar({this.person});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.grey.shade400,
      child: Center(
        child: Text(
          person.name.characters.first.toUpperCase(),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.0),
        ),
      ),
    );
  }
}
