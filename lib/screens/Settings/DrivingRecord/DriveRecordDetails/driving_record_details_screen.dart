import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zimple/extensions/future_extensions.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/model/driving.dart';
import 'package:zimple/network/firebase_drive_record_manager.dart';
import 'package:zimple/screens/Settings/DrivingRecord/CreateNewDriveRecord/add_new_drive_record_screen.dart';
import 'package:zimple/screens/Settings/DrivingRecord/DriveRecordDetails/AddNewDrive/add_new_driving_screen.dart';
import 'package:zimple/screens/Settings/DrivingRecord/DriveRecordDetails/AllDrivings/all_drivings_screen.dart';
import 'package:zimple/utils/drive_record_excel_manager.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/widgets/scaffold/zimple_scaffold.dart';

class DrivingRecordDetailsScreen extends StatefulWidget {
  final DriveJournal driveJournal;

  const DrivingRecordDetailsScreen({required this.driveJournal, super.key});

  @override
  State<DrivingRecordDetailsScreen> createState() => _DrivingRecordDetailsScreenState();
}

class _DrivingRecordDetailsScreenState extends State<DrivingRecordDetailsScreen> {
  late DriveJournal driveJournal = widget.driveJournal;
  StreamSubscription? driveJournalSubscription;

  @override
  void initState() {
    // Listen to changes to drivejournal
    Future.delayed(Duration.zero, () {
      driveJournalSubscription =
          ManagerProvider.of(context).firebaseDriveJournalManager.listenDriveJournal(driveJournal: driveJournal).listen((event) {
        print("Got new driveJournal: ${driveJournal.toJson()}");
        setState(() {
          driveJournal = event;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    driveJournalSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZimpleScaffold(
      title: driveJournal.name,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListedTitle(text: "FUNKTIONER", padding: EdgeInsets.zero),
            _buildFunctions(),
            HeightBoxes.medium,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListedTitle(text: "KÖRNINGAR", padding: EdgeInsets.zero),
                ShowAllButton(
                  onPressed: goToAllDrives,
                )
              ],
            ),
            StreamBuilder(
              stream: FirebaseDriveJournalManager.of(context).listenDrives(driveJournal: driveJournal, limit: 10),
              builder: (_, snapshot) {
                return ListedView(
                  rowInset: const EdgeInsets.symmetric(vertical: 12.0),
                  items: List.generate(
                    snapshot.data?.length ?? 0,
                    (index) {
                      var item = snapshot.data![index];
                      return _buildDriveItem(item);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ListedView _buildFunctions() {
    return ListedView(
      rowInset: const EdgeInsets.symmetric(vertical: 12.0),
      hidesSeparatorByDefault: true,
      items: [
        ListedItem(
          leadingIcon: Icons.access_time,
          text: "Skapa ny körning",
          trailingIcon: Icons.chevron_right,
          onTap: goToAddNewDriveJournal,
        ),
        ListedItem(
          text: "Redigera körjournal",
          leadingIcon: FontAwesome.pencil,
          onTap: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: AddNewDrivingRecordScreen(
                driveJournalToChange: driveJournal,
              ),
            );
          },
        ),
        ListedItem(
          text: "Exportera körjournal",
          leadingIcon: FontAwesome.doc_text,
          onTap: () async {
            shareExcelDrives().syncLoader(context);
          },
        ),
      ],
    );
  }

  ListedItem _buildDriveItem(Driving item) {
    return ListedItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${item.startAddress} - ${item.endAddress}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${dateStringVerbose(item.date)}",
            style: TextStyle(
              color: Colors.black.withOpacity(
                0.5,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        onTapDrive(driving: item);
      },
    );
  }

  Future<void> shareExcelDrives() async {
    final excel = await DriveJournalExcelManager(
      driveJournal: driveJournal,
      drivings: await FirebaseDriveJournalManager.of(context).getDrives(driveJournal: driveJournal),
    ).saveExcel();
    return Share.shareXFiles([XFile(excel)]).then((value) => null);
  }

  Future<void> goToAddNewDriveJournal() {
    return PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddNewDrivingScreen(
        driveJournal: driveJournal,
      ),
    );
  }

  Future<void> goToAllDrives() {
    return PersistentNavBarNavigator.pushNewScreen(context,
        screen: AllDrivingsScreen(
          driveJournal: driveJournal,
        ));
  }

  void onTapDriveJournal({required DriveJournal driveJournal}) {}

  void onTapDrive({required Driving driving}) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddNewDrivingScreen(
        driveJournal: driveJournal,
        drivingToChange: driving,
      ),
    );
  }
}
