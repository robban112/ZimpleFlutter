import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/model/customer.dart';

class FirebaseCustomerManager {
  String company;
  late fb.DatabaseReference database;
  late fb.DatabaseReference customerRef;
  Logger logger = Logger();
  FirebaseCustomerManager({required this.company}) {
    this.database = fb.FirebaseDatabase.instance.reference();
    this.customerRef = database.reference().child(company).child('Customers');
  }

  Future<List<Customer>> getCustomers() async {
    var snapshot = await customerRef.once();
    return _mapCustomer(snapshot);
  }

  Stream<List<Customer>> listenCustomers() {
    return customerRef.limitToLast(500).onValue.map((event) {
      print("Listen Customers");
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
      String address = customerData['address'] ?? "";
      String name = customerData['name'] ?? "";
      String orgNr = customerData['orgNr'] ?? "";
      List<Contact> contacts = _getContact(customerData);
      var customer = Customer(name, address, orgNr, contacts);
      customer.id = key;
      customers.add(customer);
    }
    return customers;
  }

  List<Contact> _getContact(dynamic customerData) {
    if (customerData['contacts'] == null) return [];
    var contactsList = List.from(customerData['contacts']);
    List<Contact> contacts = [];
    if (contactsList != null) {
      for (dynamic map in contactsList) {
        dynamic contactData = Map.from(map);
        var name = contactData['name'] ?? "";
        var email = contactData['email'] ?? "";
        var phoneNumber = contactData['phoneNumber'] ?? "";
        contacts.add(Contact("", name, phoneNumber, email));
      }
    }
    return contacts;
  }

  Future<void> addCustomer(Customer customer) {
    print("Add New Customer ${customer.name}");
    var ref = customerRef.push();
    return ref.set(customer.toJson()).then((value) => value);
  }

  Future<void> changeCustomer(Customer customer) async {
    print("Update Customer ${customer.name}");
    if (customer.id == null) return Future.error(Error);
    var ref = customerRef.child(customer.id!).update(customer.toJson()).then((value) => value);
  }

  Future<void> deleteCustomer(Customer customer) async {
    if (customer.id == null) return;
    return customerRef.child(customer.id!).remove();
  }
}
