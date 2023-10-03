import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/network/firebase_drive_journal_manager.dart';
import 'package:zimple/screens/Calendar/AddEvent/person_select_screen.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/utils/utils.dart';
import 'package:zimple/widgets/scaffold/zimple_scaffold.dart';

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
      title: "Ny körjournal",
      trailingTopNav: NavSaveButton(
        onPressed: addNewDriveJournal,
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
        )
      ],
    );
  }

  Future<void> addNewDriveJournal() async {
    Utils.setLoading(context, true);
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
    }
    Utils.setLoading(context, false);
    Navigator.of(context).pop();
  }

  Future<void> onTapAddDriver() => PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: PersonSelectScreen(
          persons: ManagerProvider.of(context).personManager.persons,
          personCallback: (persons) => setState(() => selectedPersons = persons),
          preSelectedPersons: selectedPersons,
        ),
      );
}
