import 'package:zimple/model/todo.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../managers/person_manager.dart';

class FirebaseTodoManager {
  String company;
  PersonManager personManager;
  fb.DatabaseReference todoRef;
  fb.DatabaseReference database;

  FirebaseTodoManager({@required this.company}) {
    database = fb.FirebaseDatabase.instance.reference();
    todoRef = database.reference().child(company).child('Todo');
  }

  Future<List<Todo>> getTodos() async {
    List<Todo> todos = [];

    var snapshot = await todoRef.once();
    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value);
    todos = mapTodos(mapOfMaps);
    return todos;
  }

  List<Todo> mapTodos(Map<String, dynamic> mapOfMaps) {
    List<Todo> todos = [];
    print(mapOfMaps);
    for (String key in mapOfMaps.keys) {
      dynamic todoData = mapOfMaps[key];
      if (!todoData.containsKey('date')) {
        continue;
      }
      DateTime date = DateTime.parse(todoData['date']);
      String title = todoData['title'] != null ? todoData['title'] : "";
      String todo = todoData['todo'] != null ? todoData['todo'] : "";
      String color = todoData['color'] != null ? todoData['color'] : "";

      String createdBy =
          todoData['createdBy'] != null ? todoData['createdBy'] : "";
      Todo todoObject = Todo(
          id: key,
          title: title,
          date: date,
          todo: todo,
          color: color,
          createdBy: createdBy);
      todos.add(todoObject);
    }
    print("CAME HERE");
    return todos;
  }
}
