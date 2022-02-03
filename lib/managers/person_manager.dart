import 'package:flutter/material.dart';
import '../model/person.dart';

class PersonManager {
  List<Person> persons;

  PersonManager({required this.persons});

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

  Person getPersonById(String id) {
    return persons.firstWhere((p) => p.id == id);
  }

  void updatePerson(Person person) {
    this.persons.removeWhere((p) => p.id == person.id);
    this.persons.add(person);
  }
}
