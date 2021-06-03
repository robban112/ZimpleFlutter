import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:firebase_database/firebase_database.dart' as fb;

class FirebaseOutlaysManager {
  String company;
  fb.DatabaseReference database;
  fb.DatabaseReference outlaysRef;

  FirebaseOutlaysManager({@required this.company}) {
    database = fb.FirebaseDatabase.instance.reference();
    outlaysRef = database.reference().child(company).child('Outlays');
  }
}
