import 'package:zimple/utils/date_utils.dart';

class Note {
  String id;

  final String title;

  final DateTime date;

  final String note;

  final String createdBy;

  final String? privateForUser;

  final bool isDone;

  Note({
    required this.id,
    required this.title,
    required this.date,
    required this.note,
    required this.createdBy,
    this.privateForUser,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'title': this.title,
      'date': dateStringVerbose(date),
      'note': this.note,
      'createdBy': this.createdBy,
      'privateForUser': this.privateForUser,
      'isDone': this.isDone,
    };
  }

  Note copyWith({
    String? title,
    String? note,
    DateTime? date,
    String? privateForUser,
    bool? isDone,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      createdBy: this.createdBy,
      privateForUser: privateForUser ?? this.privateForUser,
      isDone: isDone ?? this.isDone,
    );
  }
}
