import 'package:zimple/utils/date_utils.dart';

class Note {
  String id;

  final String title;

  final DateTime date;

  final String note;

  final String createdBy;

  final String createdByUid;

  final String? privateForUser;

  final bool isDone;

  Note({
    required this.id,
    required this.title,
    required this.date,
    required this.note,
    required this.createdBy,
    required this.createdByUid,
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
      'createdByUid': this.createdByUid,
      'privateForUser': this.privateForUser,
      'isDone': this.isDone,
    };
  }

  Note copyWith({
    String? title,
    String? note,
    DateTime? date,
    String? privateForUser,
    String? createdByUid,
    bool? isDone,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      createdBy: this.createdBy,
      createdByUid: createdByUid ?? this.createdByUid,
      privateForUser: privateForUser ?? this.privateForUser,
      isDone: isDone ?? this.isDone,
    );
  }
}
