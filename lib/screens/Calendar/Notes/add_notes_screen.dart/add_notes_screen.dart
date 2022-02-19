import 'package:flutter/material.dart';
import 'package:zimple/model/note.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/service/user_service.dart';
import 'package:zimple/widgets/listed_view/listed_switch.dart';
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

  bool privateNote = false;

  @override
  void initState() {
    if (widget.isChangingNote && widget.noteToChange != null) {
      titleController.text = widget.noteToChange!.title;
      noteController.text = widget.noteToChange!.note;
      privateNote = widget.noteToChange?.privateForUser != null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            onPressed: () {
              String uid = UserService.of(context).user!.uid;
              widget.isChangingNote ? _changeNote(context, uid) : _saveNote(context, uid);
            },
          ),
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    ListedTextField item = _notesItem();
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            children: [
              ListedView(
                items: [
                  ListedTextField(
                    leadingIcon: Icons.title,
                    placeholder: 'Titel',
                    controller: titleController,
                  ),
                  ListedSwitch(
                    text: 'Privat anteckning',
                    initialValue: privateNote,
                    leadingIcon: Icons.privacy_tip,
                    onChanged: (value) => setState(() => privateNote = value),
                  ),
                ],
              ),
              _buildLeadingIcon(item),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildNoteFormfield(item),
              )
            ],
          ),
        ),
      ),
    );
  }

  ListedNotefield _buildNoteFormfield(ListedTextField item) {
    return ListedNotefield(context: context, item: item);
  }

  ListedTextField _notesItem() {
    return ListedTextField(placeholder: 'Anteckningar', isMultipleLine: true, controller: noteController);
  }

  Widget _buildLeadingIcon(ListedItem item) {
    return item.leadingIcon != null
        ? Row(
            children: [
              Icon(item.leadingIcon),
              SizedBox(width: 16.0),
            ],
          )
        : Container();
  }

  void _changeNote(BuildContext context, String uid) {
    if (widget.noteToChange == null) {
      _showSnackbarError();
      Navigator.of(context).pop();
    }
    Note newNote = widget.noteToChange!.copyWith(
      title: titleController.text,
      note: noteController.text,
      date: DateTime.now(),
      privateForUser: privateNote ? uid : null,
    );
    ManagerProvider.of(context).firebaseNotesManager.changeNote(note: newNote).then((value) {
      _onSuccess();
    }).catchError((_) {
      print("Error add todo");
      _showSnackbarError();
    });
  }

  void _saveNote(BuildContext context, String uid) {
    String createdBy = ManagerProvider.of(context).user.name;
    Future<void> addNoteFuture = ManagerProvider.of(context).firebaseNotesManager.addNote(
          title: titleController.text,
          note: noteController.text,
          createdBy: createdBy,
          privateForUser: privateNote ? uid : null,
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

class ListedNotefield extends StatelessWidget {
  final ListedTextField item;

  final int numberOfLines;
  const ListedNotefield({
    Key? key,
    required this.context,
    required this.item,
    this.numberOfLines = 25,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.newline,
      //initialValue: item.initialValue,
      style: TextStyle(fontSize: 16),
      autocorrect: false,
      controller: item.controller,
      maxLines: item.isMultipleLine ? numberOfLines : null,
      focusNode: FocusNode(),
      decoration: InputDecoration(
        hintText: item.placeholder,
        hintStyle: ListedView.hintStyle(context),
        //focusColor: focusColor,
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
      ),
    );
  }
}
