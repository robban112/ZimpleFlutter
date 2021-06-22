import 'package:zimple/model/contact.dart';

class Customer {
  Customer(this.name, this.address, this.orgNr, this.contacts);
  String? id;
  String name;
  String address;
  String orgNr;
  List<Contact> contacts;

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'address': this.address,
      'orgNr': this.orgNr,
      'contacts': contacts.map((e) => e.toJson()).toList(),
    };
  }
}
