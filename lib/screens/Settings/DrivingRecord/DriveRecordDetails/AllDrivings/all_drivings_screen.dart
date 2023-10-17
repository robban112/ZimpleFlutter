import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/model/driving.dart';
import 'package:zimple/network/firebase_drive_record_manager.dart';
import 'package:zimple/screens/Settings/DrivingRecord/DriveRecordDetails/AddNewDrive/add_new_driving_screen.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/widgets/scaffold/zimple_scaffold.dart';

class AllDrivingsScreen extends StatefulWidget {
  final DriveJournal driveJournal;

  const AllDrivingsScreen({required this.driveJournal, super.key});

  @override
  State<AllDrivingsScreen> createState() => _AllDrivingsScreenState();
}

class _AllDrivingsScreenState extends State<AllDrivingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ZimpleScaffold(
      title: "Alla körningar",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDrivingInputForm(context),
      ),
    );
  }

  Widget _buildDrivingInputForm(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: FirebaseDriveJournalManager.of(context).listenDrives(driveJournal: widget.driveJournal, limit: 10),
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

  void onTapDrive({required Driving driving}) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddNewDrivingScreen(
        driveJournal: widget.driveJournal,
        drivingToChange: driving,
      ),
    );
  }
}
