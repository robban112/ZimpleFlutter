import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/model/driving.dart';
import 'package:zimple/screens/Calendar/Notes/add_notes_screen.dart/add_notes_screen.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/widgets/listed_view/listed_switch.dart';
import 'package:zimple/widgets/scaffold/zimple_scaffold.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';

class AddNewDrivingScreen extends StatefulWidget {
  final DriveJournal driveJournal;

  final Driving? drivingToChange;

  const AddNewDrivingScreen({required this.driveJournal, this.drivingToChange, super.key});

  @override
  State<AddNewDrivingScreen> createState() => _DrivingRecordDetailsScreenState();
}

class _DrivingRecordDetailsScreenState extends State<AddNewDrivingScreen> {
  late final TextEditingController startAddress = TextEditingController(text: widget.drivingToChange?.startAddress);
  late final TextEditingController endAddress = TextEditingController(text: widget.drivingToChange?.endAddress);
  late final TextEditingController startMeasurement = TextEditingController(text: widget.drivingToChange?.startMeasure);
  late final TextEditingController endMeasurement = TextEditingController(text: widget.drivingToChange?.endMeasure);
  late final TextEditingController notesController = TextEditingController(
    text: widget.drivingToChange?.driverNotesPurpose,
  );
  late bool privateDrive = widget.drivingToChange?.isPrivateDrive ?? false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ZimpleScaffold(
      title: widget.drivingToChange == null ? "Ny körning" : "Ändra körning",
      trailingTopNav: NavSaveButton(
        onPressed: onTapSaveDrive,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: _buildDrivingInputForm(context),
      ),
    );
  }

  Widget _buildDrivingInputForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListedView(
            rowInset: const EdgeInsets.symmetric(vertical: 12.0),
            items: [
              ListedSwitch(
                text: 'Privat körning',
                initialValue: privateDrive,
                leadingIcon: Icons.privacy_tip,
                onChanged: (value) => setState(() => privateDrive = value),
              ),
              ListedTextField(
                leadingIcon: FontAwesomeIcons.locationDot,
                placeholder: "Startaddress",
                onChanged: (_) => {},
                key: null,
                controller: startAddress,
                trailingWidget: GetAddressButton(controller: startAddress),
              ),
              ListedTextField(
                leadingIcon: FontAwesomeIcons.locationDot,
                placeholder: "Slutaddress",
                onChanged: (_) => {},
                key: null,
                controller: endAddress,
                trailingWidget: GetAddressButton(controller: endAddress),
              ),
              ListedTextField(
                leadingIcon: FontAwesomeIcons.ruler,
                placeholder: "Mätarställning start (km)",
                onChanged: (_) => {},
                key: null,
                controller: startMeasurement,
              ),
              ListedTextField(
                leadingIcon: FontAwesomeIcons.ruler,
                placeholder: "Mätarställning slut (km)",
                onChanged: (_) => {},
                key: null,
                controller: endMeasurement,
              ),
            ],
          ),
          ListedNotefield(
            context: context,
            numberOfLines: 10,
            item: ListedTextField(
              placeholder: 'Anteckningar',
              isMultipleLine: true,
              controller: notesController,
            ),
          )
        ],
      ),
    );
  }

  Future<void> onTapSaveDrive() async {
    final driving = Driving(
      startAddress: startAddress.text,
      endAddress: endAddress.text,
      startMeasure: startMeasurement.text,
      endMeasure: endMeasurement.text,
      driverNotesPurpose: notesController.text,
      date: DateTime.now(),
    );
    if (widget.drivingToChange == null) {
      await addNewDrive(driving: driving);
    } else {
      await changeDrive();
    }
    Navigator.of(context).pop();
  }

  Future<void> addNewDrive({required Driving driving}) {
    return ManagerProvider.of(context).firebaseDriveJournalManager.addDrive(
          driveJournal: widget.driveJournal,
          driving: driving,
        );
  }

  Future<void> changeDrive() async {
    return ManagerProvider.of(context).firebaseDriveJournalManager.changeDrive(
          driveJournal: widget.driveJournal,
          driving: widget.drivingToChange!.copyWith(
            startAddress: startAddress.text,
            endAddress: endAddress.text,
            startMeasure: startMeasurement.text,
            endMeasure: endMeasurement.text,
            driverNotesPurpose: notesController.text,
            isPrivateDrive: privateDrive,
          ),
        );
  }
}

class GetAddressButton extends StatefulWidget {
  final TextEditingController controller;

  const GetAddressButton({required this.controller, super.key});

  @override
  State<GetAddressButton> createState() => _GetAddressButtonState();
}

class _GetAddressButtonState extends State<GetAddressButton> {
  bool isLoading = false;
  LocationPermission? permission;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CupertinoActivityIndicator(color: Colors.black)
        : GestureDetector(
            onTap: onPressed,
            child: Container(
              height: 40,
              width: 60,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  "Hämta",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
  }

  void onPressed() async {
    setState(() => isLoading = true);
    var streets = await getCurrentAddress();
    if (streets != null) widget.controller.text = streets.first;
    setState(() => isLoading = false);
  }

  Future<bool> askLocationPermission() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showSnackbar(context: context, isSuccess: false, message: "Tillåt platsinfo för att visa address");
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showSnackbar(context: context, isSuccess: false, message: "Tillåt platsinfo för att visa address");
        return false;
      }
    }
    return true;
  }

  Future<List<String>?> getCurrentAddress() async {
    final hasPermission = await askLocationPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) async {
      List<Placemark> places = await placemarkFromCoordinates(position.latitude, position.longitude);
      print(places.first);
      return places.map((p) => "${p.administrativeArea}, ${p.street}").toList();
    }).catchError((e) {
      debugPrint(e);
    });
  }
}
