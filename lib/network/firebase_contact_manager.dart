import 'dart:convert';

import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:zimple/model/contact.dart';

class FirebaseContactManager {
  String company;
  late fb.DatabaseReference database;
  late fb.DatabaseReference contactRef;

  FirebaseContactManager(this.company) {
    database = fb.FirebaseDatabase.instance.reference();
    contactRef = database.reference().child(company).child('Contacts');
  }

  Future<void> addContact(Contact contact) => contactRef.push().set(contact.toJson());

  Stream<List<Contact>> listenContacts() => contactRef.onValue.map((event) => _mapSnapshot(event.snapshot));

  List<Contact> _mapSnapshot(fb.DataSnapshot snapshot) {
    if (snapshot.value == null) return [];
    try {
      print(snapshot.value);
      Map<String, dynamic> mapOfContacts = Map.from(snapshot.value);
      List<Contact> contacts = [];
      for (String key in mapOfContacts.keys) {
        Map<String, dynamic> contactData = Map.from(mapOfContacts[key]);
        Contact contact = Contact.fromJson(key, contactData);
        contacts.add(contact);
      }
      //List<Contact> contacts = mapOfContacts.keys.map((e) => Contact.fromJson(mapOfContacts[e])).toList();
      return contacts;
    } catch (error) {
      print("error parsing contacts: $error");
      return [];
    }
  }
}
