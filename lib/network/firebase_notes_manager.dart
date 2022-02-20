import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:zimple/model/note.dart';

import '../managers/person_manager.dart';
import '../model/note.dart';

class FirebaseNotesManager {
  String company;
  PersonManager personManager;
  late fb.DatabaseReference todoRef;
  late fb.DatabaseReference database;

  FirebaseNotesManager({required this.company, required this.personManager}) {
    this.database = fb.FirebaseDatabase.instance.ref();
    this.todoRef = database.ref.child(company).child('Notes');
  }

  Future<List<Note>> getTodos() async {
    List<Note> todos = [];

    var databaseEvent = await todoRef.once();
    if (databaseEvent.snapshot.value == null) return Future.value([]);
    Map<String, dynamic> mapOfMaps = Map.from(databaseEvent.snapshot.value as Map<dynamic, dynamic>);
    todos = mapTodos(mapOfMaps);
    return todos;
  }

  List<Note> mapTodos(Map<String, dynamic> mapOfMaps) {
    List<Note> todos = [];
    for (String key in mapOfMaps.keys) {
      dynamic todoData = mapOfMaps[key];
      if (!todoData.containsKey('date')) {
        continue;
      }
      DateTime date = DateTime.parse(todoData['date']);
      String title = todoData['title'] != null ? todoData['title'] : "";
      String todo = todoData['note'] != null ? todoData['note'] : "";
      String color = todoData['color'] != null ? todoData['color'] : "";
      String? privateForUser = todoData['privateForUser'] ?? null;
      bool? isDone = todoData['isDone'];

      String createdBy = todoData['createdBy'] != null ? todoData['createdBy'] : "";
      String createdByUid = todoData['createdByUid'] != null ? todoData['createdByUid'] : "";
      Note todoObject = Note(
        id: key,
        title: title,
        date: date,
        note: todo,
        createdBy: createdBy,
        createdByUid: createdByUid,
        privateForUser: privateForUser,
        isDone: isDone ?? false,
      );
      todos.add(todoObject);
    }
    return todos;
  }

  Future<void> addNote({
    required String title,
    required String note,
    required String createdBy,
    required String createdByUid,
    String? privateForUser,
  }) {
    fb.DatabaseReference ref = todoRef.push();
    if (ref.key == null) return Future.error(Error());
    Note newNote = Note(
      id: ref.key!,
      title: title,
      date: DateTime.now(),
      note: note,
      createdBy: createdBy,
      createdByUid: createdByUid,
      privateForUser: privateForUser,
      isDone: false,
    );
    return ref.set(newNote.toJson());
  }

  Future<void> changeNote({required Note note}) {
    return todoRef.child(note.id).update(note.toJson());
  }

  Future<void> removeNote({required Note note}) {
    return todoRef.child(note.id).remove();
  }
}
