import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/model/note.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';

class NoteWidget extends StatelessWidget {
  final Note note;

  final Function(Note) onPressedNote;

  const NoteWidget({
    Key? key,
    required this.note,
    required this.onPressedNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPressedNote(note),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          //boxShadow: standardShadow,
          //borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text("${note.createdBy} • ${dateString(note.date)}",
                style: TextStyle(fontSize: 12, color: ThemeNotifier.of(context).textColor.withOpacity(0.5))),
            const SizedBox(height: 8),
            Text(note.note),
          ],
        ),
      ),
    );
  }

  String get title => note.title.isEmpty ? 'Ingen titel' : note.title;
}