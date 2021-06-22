import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:firebase_database/firebase_database.dart' as fb;

class FirebaseTimeReportManager {
  String company;
  PersonManager personManager;

  late fb.DatabaseReference database;
  late fb.DatabaseReference timereportRef;

  FirebaseTimeReportManager(
      {required this.company, required this.personManager}) {
    database = fb.FirebaseDatabase.instance.reference();
    timereportRef = database.reference().child(company).child('TimeReport');
  }

  Future<void> addTimeReport(TimeReport timeReport, UserParameters user) {
    return timereportRef.child(user.token).push().set(timeReport.toJson());
  }

  fb.DatabaseReference newTimereportRef() {
    return timereportRef.push();
  }

  Future<String> addTimereportWithRef(
      fb.DatabaseReference ref, TimeReport timereport) {
    return ref.set(timereport.toJson()).then((value) => ref.key);
  }

  Stream<TimereportManager> listenTimereports(UserParameters user) {
    return timereportRef.onValue.map((tEvent) {
      var snapshot = tEvent.snapshot;
      return _mapSnapshot(snapshot);
    });
  }

  TimereportManager _mapSnapshot(fb.DataSnapshot snapshot) {
    var timereportManager = TimereportManager();
    if (snapshot.value == null) {
      return timereportManager;
    }

    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value);
    if (mapOfMaps == null) {
      return timereportManager;
    }

    // This loops through each user
    for (String key in mapOfMaps.keys) {
      dynamic userTimereports = mapOfMaps[key];
      Map<String, dynamic> timereportMap = Map.from(userTimereports);

      // This loops through each timereport of each user
      for (String key2 in timereportMap.keys) {
        dynamic timereportData = timereportMap[key2];

        var timereport = TimeReport.mapFromSnapshot(timereportData);
        timereport.id = key2;
        timereport.userId = key;
        timereportManager.addTimereport(userId: key, timeReport: timereport);
      }
    }
    return timereportManager;
  }
}
