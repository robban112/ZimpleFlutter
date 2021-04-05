import 'package:zimple/model/todo.dart';
import 'package:flutter/material.dart';

class TodoDetailScreen extends StatelessWidget {
  static const String routeName = "todo_detail_screen";
  Todo todo;
  TodoDetailScreen({this.todo});
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    textEditingController.text = todo.todo;
    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10.0, top: 25.0, right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
            FlatButton(
              child: Text(
                'Spara',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
              ),
              color: Colors.orange,
              onPressed: () => {print('SAVED!')},
            ),
          ],
        ),
      ),
    );
  }
}
