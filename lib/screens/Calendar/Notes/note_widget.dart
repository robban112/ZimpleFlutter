import 'package:flutter/material.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/note.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

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
    return Opacity(
      opacity: note.isDone ? 0.5 : 1,
      child: InkWell(
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
              Row(
                children: [
                  ProfilePictureIcon(person: PersonManager.of(context).getPersonById(note.createdByUid), size: Size(30, 30)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${note.createdBy} • ${dateString(note.date)}",
                          style: TextStyle(fontSize: 12, color: ThemeNotifier.of(context).textColor.withOpacity(0.5))),
                      //const SizedBox(height: 3),
                      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(note.note),
              if (note.isDone) const SizedBox(height: 8),
              if (note.isDone) _buildDoneCircleText()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneCircleText() {
    return Row(
      children: [
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text("Klar"),
      ],
    );
  }

  String get title => note.title.isEmpty ? 'Ingen titel' : note.title;
}
