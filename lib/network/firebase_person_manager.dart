import 'package:firebase_database/firebase_database.dart';
import 'package:zimple/model/user_parameters.dart';
import '../model/person.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class FirebasePersonManager {
  String company;
  DatabaseReference personsRef;
  DatabaseReference database;
  FirebasePersonManager({@required this.company}) {
    database = FirebaseDatabase.instance.reference();
    personsRef = database.reference().child(company).child('Persons');
  }

  Future<List<Person>> getPersons() async {
    var snapshot = await personsRef.once();
    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value);
    List<Person> persons = [];
    for (String key in mapOfMaps.keys) {
      dynamic personData = mapOfMaps[key];
      persons.add(
        Person(
            color: hexToColor(personData['color']),
            name: personData['name'],
            id: personData['id'].toString(),
            email: personData['email'],
            profilePicturePath: personData['profilePicturePath'],
            phonenumber: personData['phonenumber']),
      );
    }
    return persons;
  }

  Future<void> setUserProfileImage(UserParameters user, String filePath) {
    personsRef.child(user.token).child("profilePicturePath").set(filePath);
  }
}
