import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:rxdart/subjects.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_notes_manager.dart';
import 'package:zimple/screens/Calendar/Notes/add_notes_screen.dart/add_notes_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/service/user_service.dart';
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

  late TabController _tabController = TabController(length: 2, vsync: this);

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
      body: _body(context),
    );
  }

  // MARK: Builder Methods

  Widget _body(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            physics: BouncingScrollPhysics(),
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            tabs: _tabs(context),
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              child: TabBarView(
                controller: _tabController,
                physics: BouncingScrollPhysics(),
                children: [
                  _buildNoteStream(false),
                  _buildNoteStream(true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text) {
    return Container(
      height: 50,
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  List<Widget> _tabs(BuildContext context) {
    return [
      _buildTab(context, "Delade"),
      _buildTab(context, "Privata"),
    ];
  }

  StreamBuilder<List<Note>> _buildNoteStream(bool isPrivate) {
    return StreamBuilder(
        stream: notesStream,
        builder: (context, AsyncSnapshot<List<Note>> snapshot) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _snapshotMapper(snapshot, isPrivate),
          );
        });
  }

  Widget _snapshotMapper(AsyncSnapshot<List<Note>> snapshot, bool isPrivate) {
    if (snapshot.hasError) return _error();
    if (!snapshot.hasData || snapshot.data == null)
      return _loading();
    else
      return _buildNotes(listNotes: snapshot.data!, isPrivate: isPrivate);
  }

  Widget _error() {
    return Center(key: ValueKey('error'), child: Text("Något oväntat fel har inträffad"));
  }

  Widget _loading() {
    return Center(key: ValueKey('loading'), child: CupertinoActivityIndicator());
  }

  Widget _buildNotes({required List<Note> listNotes, required bool isPrivate}) {
    print("isprivate: $isPrivate");
    if (listNotes.length == 0) return _emptyNotes();
    List<Note> _notes = [];
    if (isPrivate) {
      _notes = listNotes.where((note) => note.privateForUser == UserService.of(context).user!.uid).toList();
    } else {
      _notes = listNotes.where((note) => note.privateForUser == null).toList();
    }
    return ListView.separated(
      key: ValueKey(_notes.hashCode.toString()),
      itemBuilder: (context, index) {
        Note note = _notes[index];
        return Dismissible(
          dismissThresholds: {
            DismissDirection.endToStart: 0.4,
            DismissDirection.startToEnd: 0.4,
          },
          confirmDismiss: (direction) {
            if (direction == DismissDirection.endToStart) {
              return showAlertDialog(context: context, title: 'Ta bort anteckning', subtitle: 'Är du säker?')
                  .then<bool>((value) => false);
            } else {
              return Future.value(true);
            }
          },
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              _notes.remove(note);
              _removeNote(note);
            } else if (direction == DismissDirection.startToEnd) {
              _markNoteComplete(note);
            }
          },
          direction: DismissDirection.horizontal,
          background: _buildDismissBackground(),
          key: Key(note.note + note.createdBy + note.date.toString()),
          child: NoteWidget(
            note: note,
            onPressedNote: _goToChangeNote,
          ),
        );
      },
      itemCount: _notes.length,
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

  Widget _buildDismissBackground() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            color: Colors.green,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Icon(
                  FontAwesome5.check,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
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
          ),
        ),
      ],
    );
  }

  // MARK: Network

  Future<void> _markNoteComplete(Note note) {
    print("mark note as complete");
    Note newNote = note.copyWith(
      isDone: !note.isDone,
    );
    return ManagerProvider.of(context).firebaseNotesManager.changeNote(note: newNote).then((value) {
      _fetchNotes(context);
    });
  }

  Future<void> _removeNote(Note note) {
    return ManagerProvider.of(context).firebaseNotesManager.removeNote(note: note);
  }

  void _fetchNotes(BuildContext context) {
    ManagerProvider.of(context).firebaseNotesManager.getTodos().then((value) {
      value.sort((a, b) => b.date.compareTo(a.date));
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
