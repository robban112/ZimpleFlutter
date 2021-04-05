import 'package:flutter/material.dart';

class Todo {
  String id;
  String title;
  String color;
  DateTime date;
  String todo;
  String createdBy;

  Todo(
      {@required this.id,
      @required this.title,
      @required this.color,
      @required this.date,
      @required this.todo,
      @required this.createdBy});
}
