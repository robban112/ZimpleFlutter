import 'package:firebase_database/firebase_database.dart';

abstract class NetworkManager {
  final String company;

  final DatabaseReference ref;

  final String key;

  NetworkManager({required this.company, required this.key})
      : ref = FirebaseDatabase.instance.ref().ref.child(company).child(key);
}
