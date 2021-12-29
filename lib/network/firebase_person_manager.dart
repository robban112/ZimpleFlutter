import 'package:firebase_database/firebase_database.dart';
import 'package:zimple/model/user_parameters.dart';
import '../model/person.dart';
import '../utils/color_utils.dart';

class FirebasePersonManager {
  String company;
  late DatabaseReference personsRef;
  late DatabaseReference database;
  FirebasePersonManager({required this.company}) {
    database = FirebaseDatabase.instance.reference();
    personsRef = database.reference().child(company).child('Persons');
  }

  Future<List<Person>> getPersons() async {
    var snapshot = await personsRef.once();
    List<Person> persons = _mapSnapshot(snapshot);
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
    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value);
    List<Person> persons = [];
    for (String key in mapOfMaps.keys) {
      dynamic personData = mapOfMaps[key];
      persons.add(
        Person(
          color: hexToColor(personData['color']),
          name: personData['name'] ?? "",
          id: personData['id'].toString(),
          email: personData['email'],
          profilePicturePath: personData['profilePicturePath'],
          phonenumber: personData['phonenumber'],
          iOSLink: personData['iOSLink'],
          androidLink: personData['androidLink'],
          ssn: personData['ssn'],
          address: personData['address'],
        ),
      );
    }
    return persons;
  }

  Future<void> setUserProfileImage(UserParameters user, String filePath) async {
    personsRef.child(user.token).child("profilePicturePath").set(filePath);
  }

  Future<void> setUserProps(Person person) => personsRef.child(person.id).set(person.toJson());
}
