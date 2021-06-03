import 'package:flutter/material.dart';
import 'person.dart';
import '../utils/date_utils.dart';

class Event {
  DateTime start;
  DateTime end;
  String title;
  Color color;
  String id;
  String customer;
  String location;
  String phoneNumber;
  String notes;
  String customerKey;
  int customerContactIndex;
  List<String> timereported;
  List<Person> persons;
  List<String> imageStoragePaths;
  Map<String, dynamic> originalImageStoragePaths;

  bool hasCurrentUserTimereported;

  Event(
      {this.id,
      @required this.start,
      @required this.end,
      @required this.persons,
      this.color,
      this.title,
      this.customer,
      this.location,
      this.phoneNumber,
      this.notes,
      this.imageStoragePaths,
      this.originalImageStoragePaths,
      this.customerKey,
      this.customerContactIndex,
      this.timereported});

  Map<String, dynamic> toJson() {
    return {
      'title': this.title == null ? "" : this.title,
      'address': this.location == null ? "" : this.location,
      'customer': this.customer == null ? "" : this.customer,
      'phonenumber': this.phoneNumber == null ? "" : this.phoneNumber,
      'startDate': dateStringVerbose(start),
      'endDate': dateStringVerbose(end),
      'anteckning': this.notes == null ? "" : this.notes,
      'persons': persons.map((e) => e.id).toList(),
      'images': originalImageStoragePaths,
      'customerKey': this.customerKey == null ? "" : this.customerKey,
      'customerContactIndex': this.customerContactIndex,
      'timereported': this.timereported
    };
  }
}
