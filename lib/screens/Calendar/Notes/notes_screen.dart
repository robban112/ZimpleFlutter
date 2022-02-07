import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:rxdart/subjects.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_notes_manager.dart';
import 'package:zimple/screens/Calendar/Notes/add_notes_screen.dart/add_notes_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/alert_dialog/alert_dialog.dart';
import 'package:zimple/widgets/floating_add_button.dart';
import 'package:zimple/widgets/widgets.dart';

import 'note_widget.dart';

class NotesScreen extends StatefulWidget {
  final FirebaseNotesManager firebaseNotesManager;
  NotesScreen({
    Key? key,
    required this.firebaseNotesManager,
  }) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  BehaviorSubject<List<Note>> notesStream = BehaviorSubject();

  @override
  void dispose() {
    notesStream.close();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _fetchNotes(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingAddButton(
        onPressed: _goToAddNote,
      ),
      appBar: PreferredSize(
        preferredSize: appBarSize,
        child: StandardAppBar("Anteckningar"),
      ),
      body: _body(),
    );
  }

  // MARK: Builder Methods

  Widget _body() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
      ),
      child: StreamBuilder(
          stream: notesStream,
          builder: (context, AsyncSnapshot<List<Note>> snapshot) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _snapshotMapper(snapshot),
            );
          }),
    );
  }

  Widget _snapshotMapper(AsyncSnapshot<List<Note>> snapshot) {
    if (snapshot.hasError) return _error();
    if (!snapshot.hasData || snapshot.data == null)
      return _loading();
    else
      return _notes(notes: snapshot.data!);
  }

  Widget _error() {
    return Center(key: ValueKey('error'), child: Text("Något oväntat fel har inträffad"));
  }

  Widget _loading() {
    return Center(key: ValueKey('loading'), child: CupertinoActivityIndicator());
  }

  Widget _notes({required List<Note> notes}) {
    if (notes.length == 0) return _emptyNotes();
    return ListView.separated(
      key: ValueKey(notes.hashCode.toString()),
      itemBuilder: (context, index) {
        Note note = notes[index];
        return Dismissible(
          confirmDismiss: (direction) {
            return showAlertDialog(context: context, title: 'Ta bort anteckning', subtitle: 'Är du säker?');
          },
          onDismissed: (_) {
            notes.remove(note);
            _removeNote(note);
          },
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          key: Key(note.note + note.createdBy + note.date.toString()),
          child: NoteWidget(
            note: note,
            onPressedNote: _goToChangeNote,
          ),
        );
      },
      itemCount: notes.length,
      separatorBuilder: (_, __) => _buildSeparator(),
    );
  }

  Widget _emptyNotes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          "Inga anteckningar tillagda än. Lägg till en anteckning genom att trycka på plusset!",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Padding _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Divider(height: 0.4, color: Theme.of(context).dividerColor),
    );
  }

  Container _buildDismissBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(
            FontAwesome5.trash,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // MARK: Network

  Future<void> _removeNote(Note note) {
    return ManagerProvider.of(context).firebaseNotesManager.removeNote(note: note);
  }

  void _fetchNotes(BuildContext context) {
    ManagerProvider.of(context).firebaseNotesManager.getTodos().then((value) {
      notesStream.add(value);
    });
  }

  void _goToChangeNote(Note note) {
    Navigator.of(context).push(_addNoteRoute(true, note));
  }

  void _goToAddNote() {
    Navigator.of(context).push(_addNoteRoute(false, null));
  }

  CupertinoPageRoute _addNoteRoute(bool isChangingNote, Note? noteToChange) {
    return CupertinoPageRoute(
      builder: (context) => AddNotesScreen(
        isChangingNote: isChangingNote,
        noteToChange: noteToChange,
        onNoteSaved: () => _fetchNotes(context),
      ),
    );
  }
}
