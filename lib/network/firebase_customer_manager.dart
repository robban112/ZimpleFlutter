import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/model/customer.dart';

class FirebaseCustomerManager {
  String company;
  fb.DatabaseReference database;
  fb.DatabaseReference customerRef;
  FirebaseCustomerManager({@required this.company}) {
    database = fb.FirebaseDatabase.instance.reference();
    customerRef = database.reference().child(company).child('Customers');
  }

  Stream<List<Customer>> listenCustomers() {
    return customerRef.limitToLast(500).onValue.map((event) {
      var snapshot = event.snapshot;
      return _mapCustomer(snapshot);
      //return _mapSnapshot(snapshot);
    });
  }

  List<Customer> _mapCustomer(fb.DataSnapshot snapshot) {
    List<Customer> customers = [];
    if (snapshot.value == null) {
      return [];
    }
    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value);
    if (mapOfMaps == null) {
      return [];
    }
    for (String key in mapOfMaps.keys) {
      dynamic customerData = mapOfMaps[key];
      var address = customerData['address'];
      var name = customerData['name'];
      var contacts = _getContact(customerData);
      var customer = Customer(name, address, contacts);
      customer.id = key;
      customers.add(customer);
    }
    return customers;
  }

  List<Contact> _getContact(dynamic customerData) {
    var contactsList = List.from(customerData['contacts']);
    List<Contact> contacts = [];
    if (contactsList != null) {
      for (dynamic map in contactsList) {
        dynamic contactData = Map.from(map);
        var name = contactData['name'];
        var email = contactData['email'];
        var phoneNumber = contactData['phoneNumber'];
        contacts.add(Contact(name, phoneNumber, email));
      }
    }
    return contacts;
  }

  Future<void> addCustomer(Customer customer) {
    var ref = customerRef.push();
    return ref.set(customer.toJson()).then((value) => value);
  }
}
