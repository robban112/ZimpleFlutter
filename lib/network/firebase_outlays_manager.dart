import 'package:firebase_database/firebase_database.dart' as fb;

class FirebaseOutlaysManager {
  String company;
  late fb.DatabaseReference database;
  late fb.DatabaseReference outlaysRef;

  FirebaseOutlaysManager({required this.company}) {
    database = fb.FirebaseDatabase.instance.reference();
    outlaysRef = database.reference().child(company).child('Outlays');
  }
}
