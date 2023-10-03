import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/drive_journal.dart';
import 'package:zimple/model/driving.dart';
import 'package:zimple/network/network_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';

class FirebaseDriveJournalManager extends NetworkManager {
  final String company;

  final PersonManager personManager;

  static FirebaseDriveJournalManager of(BuildContext context) => context.read<ManagerProvider>().firebaseDriveJournalManager;

  static const drivingKey = "Drivings";

  FirebaseDriveJournalManager({
    required this.personManager,
    required this.company,
  }) : super(company: company, key: "DriveJournal");

  Future<void> createDriveJournal({required DriveJournal driveJournal}) async {
    var newDriveJournal = ref.push();
    await newDriveJournal.set(driveJournal.toJson());
  }

  Stream<List<DriveJournal>> getDriveJournals() {
    return ref.onValue.map(
      (event) {
        try {
          return _mapDriveJournal(event.snapshot);
        } catch (error) {
          print(error);
        }
        return [];
      },
    );
  }

  List<DriveJournal> _mapDriveJournal(DataSnapshot snapshot) {
    List<DriveJournal> driveJournals = [];
    if (snapshot.value == null) return [];
    Map<String, dynamic>? mapOfMaps = Map.from(snapshot.value as Map<dynamic, dynamic>);

    for (String key in mapOfMaps.keys) {
      Map<Object?, Object?> journalData = mapOfMaps[key];
      var journal = DriveJournal.fromJson(journalData, key, personManager);
      driveJournals.add(journal);
    }

    return driveJournals;
  }

  Future<List<Driving>> getDrives({required DriveJournal driveJournal}) async {
    if (driveJournal.id.isEmpty) return [];
    var snapshot = await ref.child(driveJournal.id).child(drivingKey).get();
    return _mapDrives(snapshot)!;
  }

  List<Driving>? _mapDrives(DataSnapshot snapshot) {
    List<Driving> drives = [];
    if (snapshot.value == null) return null;
    Map<String, dynamic>? mapOfMaps = Map.from(snapshot.value as Map<dynamic, dynamic>);

    for (String key in mapOfMaps.keys) {
      Map<Object?, Object?> data = mapOfMaps[key];
      var journal = Driving.fromJson(data, key);
      drives.add(journal);
    }

    return drives;
  }

  Future<void> changeDrive({required DriveJournal driveJournal, required Driving driving}) async {
    if (driveJournal.id.isEmpty) return;
    var drivingRef = ref.child(driveJournal.id).child(drivingKey).child(driving.id);
    return drivingRef.update(driving.toJson());
  }

  Future<void> addDrive({required DriveJournal driveJournal, required Driving driving}) async {
    if (driveJournal.id.isEmpty) return;
    var driveJournalRef = ref.child(driveJournal.id).child(drivingKey).push();
    return driveJournalRef.set(driving.toJson());
  }

  Stream<List<Driving>?> listenDrives({required DriveJournal driveJournal, int? limit}) {
    Query refDriveJournal = ref.child(driveJournal.id).child(drivingKey);
    if (limit != null) {
      refDriveJournal = refDriveJournal.limitToFirst(limit);
    }
    return refDriveJournal.onValue.map((event) => _mapDrives(event.snapshot));
  }
}

// abstract class FirebaseListModel<T extends Model> extends NetworkManager {
//   FirebaseListModel({required super.company, required super.key});

//   Future<List<T>> getModels() {
//     var snapshot = await ref.get();
//     List<DriveJournal> driveJournals = [];
//     if (snapshot.value == null) return [];
//     Map<String, dynamic>? mapOfMaps = Map.from(snapshot.value as Map<dynamic, dynamic>);

//     for (String key in mapOfMaps.keys) {
//       Map<Object?, Object?> journalData = mapOfMaps[key];
//       var journal = Model.fromJson(journalData, key);
//       driveJournals.add(journal);
//     }

//     return driveJournals;
//   }

//   Future<void> updateModel();

//   Future<void> addModel();
// }
