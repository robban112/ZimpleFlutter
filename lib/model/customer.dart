import 'package:flutter/material.dart';
import 'package:zimple/model/contact.dart';

class Customer {
  Customer(this.name, this.address, this.contacts);
  String id;
  final String name;
  final String address;
  final List<Contact> contacts;

  Map<String, dynamic> toJson() {
    var test = {
      'name': this.name == null ? "" : this.name,
      'address': this.address == null ? "" : this.address,
      'contacts': contacts.map((e) => e.toJson()).toList().asMap(),
    };
    print(test);
    return {
      'name': this.name == null ? "" : this.name,
      'address': this.address == null ? "" : this.address,
      'contacts': contacts.map((e) => e.toJson()).toList(),
    };
  }
}
