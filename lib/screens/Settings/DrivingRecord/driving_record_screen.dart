import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/screens/Settings/DrivingRecord/CreateNewDriveRecord/add_new_drive_record_screen.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/widgets/scaffold/zimple_scaffold.dart';

import 'DriveRecordDetails/driving_record_details_screen.dart';

class DrivingRecordScreen extends StatefulWidget {
  const DrivingRecordScreen({super.key});

  @override
  State<DrivingRecordScreen> createState() => _DrivingRecordScreenState();
}

class _DrivingRecordScreenState extends State<DrivingRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return ZimpleScaffold(
      title: "Körjournal",
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Spara dina körningar manuellt med hjälp av Zimple. Godkänt av Skatteverket"),
            HeightBoxes.medium,
            ListedTitle(text: "FUNKTIONER", padding: EdgeInsets.zero),
            ListedView(
              rowInset: const EdgeInsets.symmetric(vertical: 12.0),
              items: [
                ListedItem(
                  leadingIcon: Icons.access_time,
                  text: "Skapa ny körjournal",
                  trailingIcon: Icons.chevron_right,
                  onTap: goToAddNewDriveJournal,
                ),
              ],
            ),
            HeightBoxes.small,
            ListedTitle(text: "KÖRJOURNALER", padding: EdgeInsets.zero),
            StreamBuilder(
              stream: ManagerProvider.of(context).firebaseDriveJournalManager.getDriveJournals(),
              builder: (_, snapshot) {
                return ListedView(
                  rowInset: const EdgeInsets.symmetric(vertical: 12.0),
                  items: List.generate(
                    snapshot.data?.length ?? 0,
                    (index) {
                      var item = snapshot.data![index];
                      return ListedItem(
                        leadingWidget: ProfilePictureIcon(
                          person: ManagerProvider.of(context).getLoggedInPerson(),
                          size: Size(32, 32),
                          fontSize: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              dateString(
                                item.createdAt,
                              ),
                              style: TextStyle(color: Colors.black.withOpacity(0.5)),
                            ),
                          ],
                        ),
                        onTap: () => onTapDriveJournal(driveJournal: item),
                      );
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

  Future<void> goToAddNewDriveJournal() {
    return PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddNewDrivingRecordScreen(),
    );
  }

  Future<void> onTapDriveJournal({required DriveJournal driveJournal}) {
    return PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: DrivingRecordDetailsScreen(
        driveJournal: driveJournal,
      ),
    );
  }
}
