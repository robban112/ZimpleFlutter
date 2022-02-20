import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zimple/widgets/widgets.dart';

import '../model/person.dart';

class PersonManager {
  List<Person> persons;

  PersonManager({required this.persons});

  static PersonManager of(BuildContext context) => context.read<ManagerProvider>().personManager;

  List<Person> getPersonsByIds(List<String> personIds) {
    List<Person> _persons = [];
    personIds.forEach((id) {
      try {
        Person person = persons.firstWhere((person) => person.id == id);
        if (person != null) {
          _persons.add(person);
        } else {
          throw ("ERROR RETRIEVING PERSON ID");
        }
      } catch (error) {
        print("Unable to retrieve persons for ids: $personIds, in person list: ${this.persons.map((e) => e.id).toList()}");
        print(error);
      }
    });
    return _persons;
  }

  List<String> getPersonIds() => this.persons.map((person) => person.id).toList();

  List<String> getProfilePicturePaths() => this.persons.map((person) => person.profilePicturePath).whereType<String>().toList();

  Person? getPersonById(String id) {
    try {
      return persons.firstWhere((p) => p.id == id, orElse: null);
    } catch (error) {
      return null;
    }
  }

  void updatePerson(Person person) {
    this.persons.removeWhere((p) => p.id == person.id);
    this.persons.add(person);
  }
}
