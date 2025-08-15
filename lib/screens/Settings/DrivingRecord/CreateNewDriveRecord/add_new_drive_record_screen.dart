import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/network/firebase_drive_record_manager.dart';
import 'package:zimple/screens/Calendar/AddEvent/person_select_screen.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/utils/utils.dart';
import 'package:zimple/widgets/scaffold/zimple_scaffold.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';

class AddNewDrivingRecordScreen extends StatefulWidget {
  final DriveJournal? driveJournalToChange;
  const AddNewDrivingRecordScreen({this.driveJournalToChange, super.key});

  @override
  State<AddNewDrivingRecordScreen> createState() => _AddNewDrivingRecordScreenState();
}

class _AddNewDrivingRecordScreenState extends State<AddNewDrivingRecordScreen> {
  late final TextEditingController nameController = TextEditingController(text: widget.driveJournalToChange?.name);
  late final TextEditingController regNrController = TextEditingController(text: widget.driveJournalToChange?.regNr);
  late final TextEditingController measurementController = TextEditingController(
    text: widget.driveJournalToChange?.measurement.toString(),
  );

  bool isLoading = false;

  late List<Person> selectedPersons = widget.driveJournalToChange?.drivers ?? [];

  @override
  Widget build(BuildContext context) {
    return ZimpleScaffold(
      title: widget.driveJournalToChange == null ? "Ny körjournal" : "Ändra körjournal",
      trailingTopNav: NavSaveButton(
        onPressed: onPressedSave,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ListedView _buildInput() {
    return ListedView(
      rowInset: const EdgeInsets.symmetric(vertical: 12.0),
      items: [
        ListedTextField(
          leadingIcon: FeatherIcons.info,
          placeholder: "Namn",
          onChanged: (_) => {},
          key: null,
          controller: nameController,
        ),
        ListedTextField(
          leadingIcon: FontAwesomeIcons.hashtag,
          placeholder: "Registreringsnummer",
          onChanged: (_) => {},
          key: null,
          controller: regNrController,
        ),
        ListedTextField(
          leadingIcon: FontAwesomeIcons.hashtag,
          placeholder: "Mätarställning (km)",
          onChanged: (_) => {},
          key: null,
          controller: measurementController,
        ),
        ListedItem(
          leadingIcon: FeatherIcons.userPlus,
          text: "Förare",
          onTap: onTapAddDriver,
          trailingWidget: Row(
            children: [
              ListPersonCircleAvatar(
                widthMultiplier: 0.5,
                persons: selectedPersons,
                alignment: WrapAlignment.end,
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
        if (widget.driveJournalToChange != null)
          ListedItem(
            leadingWidget: Icon(FeatherIcons.trash, color: Colors.red),
            text: "Ta bort körjournal",
            textStyle: TextStyle(color: Colors.red),
            onTap: deleteDriveJournal,
          )
      ],
    );
  }

  Future<void> onPressedSave() async {
    Utils.setLoading(context, true);
    if (widget.driveJournalToChange != null) {
      // CHANGE
      await changeDriveJournal();
      showSnackbar(context: context, isSuccess: true, message: "Körjournal ändrad!");
    } else {
      showSnackbar(context: context, isSuccess: true, message: "Körjournal tillagd!");
      await addNewDriveJournal();
    }
    Navigator.of(context).pop();
    Utils.setLoading(context, false);
  }

  Future<void> changeDriveJournal() {
    return FirebaseDriveJournalManager.of(context).updateDriveJournal(newDriveJournal: getDriveJournal());
  }

  Future<void> addNewDriveJournal() async {
    try {
      await FirebaseDriveJournalManager.of(context).createDriveJournal(
        driveJournal: DriveJournal(
          regNr: regNrController.text,
          year: DateTime.now().year.toString(),
          name: nameController.text,
          createdBy: loggedInPerson(context)!.id,
          createdAt: DateTime.now(),
          drivers: selectedPersons,
          measurement: double.parse(measurementController.text),
        ),
      );
    } catch (error) {
      print(error);
      Utils.setLoading(context, false);
    }
  }

  DriveJournal getDriveJournal() => DriveJournal(
        id: widget.driveJournalToChange?.id ?? "",
        regNr: regNrController.text,
        year: DateTime.now().year.toString(),
        name: nameController.text,
        createdBy: loggedInPerson(context)!.id,
        createdAt: DateTime.now(),
        drivers: selectedPersons,
        measurement: double.parse(measurementController.text),
      );

  Future<void> onTapAddDriver() => PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: PersonSelectScreen(
          persons: ManagerProvider.of(context).personManager.persons,
          personCallback: (persons) => setState(() => selectedPersons = persons),
          preSelectedPersons: selectedPersons,
        ),
      );

  Future<void> deleteDriveJournal() async {
    // Confirm
    bool confirm = await Utils.showAlertDialog(context, title: "Ta bort körjournal", subtitle: "Detta kan inte ångras");
    if (!confirm) return;
    Utils.setLoading(context, true);
    await FirebaseDriveJournalManager.of(context).deleteDriveRecord(driveJournal: widget.driveJournalToChange!);
    showSnackbar(context: context, isSuccess: true, message: "Körjournal borttagen");
    Utils.setLoading(context, false);
    Navigator.of(context).pop();
    await Future.delayed(Duration(milliseconds: 300), () {
      Navigator.of(context).pop();
    });

    // Delete
  }
}
