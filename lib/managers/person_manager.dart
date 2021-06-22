import 'package:flutter/material.dart';
import '../model/person.dart';

class PersonManager {
  List<Person> persons;

  PersonManager({required this.persons});

  List<Person> getPersonsByIds(List<String> personIds) {
    List<Person> _persons = [];
    personIds.forEach((id) {
      Person person = persons.firstWhere((person) => person.id == id);
      if (person != null) {
        _persons.add(person);
      } else {
        throw ("ERROR RETRIEVING PERSON ID");
      }
    });
    return _persons;
  }

  Person getPersonById(String id) {
    return persons.firstWhere((p) => p.id == id);
  }
}
