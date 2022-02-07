import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zimple/model/note.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class AddNotesScreen extends StatefulWidget {
  final bool isChangingNote;

  final Note? noteToChange;

  final VoidCallback onNoteSaved;

  AddNotesScreen({
    Key? key,
    this.isChangingNote = false,
    this.noteToChange,
    required this.onNoteSaved,
  }) : super(key: key);

  @override
  _AddNotesScreenState createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  TextEditingController titleController = TextEditingController();

  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    if (widget.isChangingNote && widget.noteToChange != null) {
      titleController.text = widget.noteToChange!.title;
      noteController.text = widget.noteToChange!.note;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: appBarSize,
        child: StandardAppBar(
          widget.isChangingNote ? "Ändra anteckning" : "Ny Anteckning",
          trailing: TextButton(
            child: Text(
              "Spara",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            onPressed: () => widget.isChangingNote ? _changeNote(context) : _saveNote(context),
          ),
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: ListedView(items: [
        ListedTextField(
          leadingIcon: Icons.title,
          placeholder: 'Titel',
          controller: titleController,
        ),
        ListedTextField(
          placeholder: 'Anteckning',
          controller: noteController,
          isMultipleLine: true,
          inputType: TextInputType.multiline,
        )
      ]),
    );
  }

  void _changeNote(BuildContext context) {
    if (widget.noteToChange == null) {
      _showSnackbarError();
      Navigator.of(context).pop();
    }
    Note newNote = widget.noteToChange!.copyWith(
      title: titleController.text,
      note: noteController.text,
      date: DateTime.now(),
    );
    ManagerProvider.of(context).firebaseNotesManager.changeNote(note: newNote).then((value) {
      _onSuccess();
    }).catchError((_) {
      print("Error add todo");
      _showSnackbarError();
    });
  }

  void _saveNote(BuildContext context) {
    String createdBy = ManagerProvider.of(context).user.name;
    Future<void> addNoteFuture = ManagerProvider.of(context).firebaseNotesManager.addNote(
          title: titleController.text,
          note: noteController.text,
          createdBy: createdBy,
        );
    addNoteFuture.then((value) {
      _onSuccess();
    }).catchError((_) {
      print("Error add todo");
      _showSnackbarError();
    });
  }

  void _onSuccess() {
    _showSnackbarSuccess();
    widget.onNoteSaved();
    Navigator.of(context).pop();
  }

  void _showSnackbarError() {
    showSnackbar(context: context, isSuccess: false, message: "Det vart tyvärr något fel");
  }

  void _showSnackbarSuccess() {
    Future.delayed(Duration(milliseconds: 300), () {
      String message = widget.isChangingNote ? "Anteckning ändrad" : "Anteckning tillagd!";
      showSnackbar(context: context, isSuccess: true, message: message);
    });
  }
}
