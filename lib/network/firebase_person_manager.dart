import 'package:firebase_database/firebase_database.dart';
import 'package:zimple/model/user_parameters.dart';

import '../model/person.dart';

class FirebasePersonManager {
  String company;
  late DatabaseReference personsRef;
  late DatabaseReference database;
  FirebasePersonManager({required this.company}) {
    database = FirebaseDatabase.instance.ref();
    personsRef = database.ref.child(company).child('Persons');
  }

  Future<List<Person>> getPersons() async {
    var databaseEvent = await personsRef.once();
    List<Person> persons = _mapSnapshot(databaseEvent.snapshot);
    return persons;
  }

  Stream<List<Person>> listenPersons() {
    return personsRef.onValue.map((eventPersons) {
      print("Listening value persons");
      var snapshot = eventPersons.snapshot;
      return _mapSnapshot(snapshot);
    });
  }

  List<Person> _mapSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value as Map<dynamic, dynamic>);
    List<Person> persons = [];
    for (String key in mapOfMaps.keys) {
      dynamic personData = mapOfMaps[key];
      try {
        persons.add(
          Person.fromJson(personData, key: key),
        );
      } catch (error) {
        print("Unable to parse person: ${personData.toString()} key: ${snapshot.key}");
      }
    }
    return persons;
  }

  Future<void> setUserProfileImage(UserParameters user, String filePath) async {
    personsRef.child(user.token).child("profilePicturePath").set(filePath);
  }

  Future<void> setUserProps(Person person) => personsRef.child(person.id).set(person.toJson());
}
