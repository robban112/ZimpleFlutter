import 'package:zimple/utils/date_utils.dart';

class Note {
  String id;
  final String title;
  final DateTime date;
  final String note;
  final String createdBy;

  Note({
    required this.id,
    required this.title,
    required this.date,
    required this.note,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'title': this.title,
      'date': dateStringVerbose(date),
      'note': this.note,
      'createdBy': this.createdBy,
    };
  }

  Note copyWith({String? title, String? note, DateTime? date}) {
    return Note(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      createdBy: createdBy,
    );
  }
}
