import 'package:flutter/material.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/event_layout.dart';
import 'package:zimple/model/event_type.dart';
import 'package:zimple/model/work_category.dart';
import 'person.dart';
import '../utils/date_utils.dart';

class Event {
  DateTime start;
  DateTime end;
  String title;
  Color color;
  String id;
  EventType eventType;
  String? customer;
  String? location;
  String? phoneNumber;
  String? notes;
  String? customerKey;
  int? workCategoryId;
  String? contactKey;

  Customer? customerRef;

  bool isMovingEvent;

  late EventLayout layout;

  int? customerContactIndex;
  List<String>? timereported;
  List<Person>? persons;
  List<String>? imageStoragePaths;
  Map<String, dynamic>? originalImageStoragePaths;

  Event({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.eventType,
    this.persons,
    this.color = Colors.white,
    this.customer,
    this.location,
    this.phoneNumber,
    this.notes,
    this.imageStoragePaths,
    this.originalImageStoragePaths,
    this.customerKey,
    this.customerContactIndex,
    this.timereported,
    this.workCategoryId,
    this.contactKey,
    this.isMovingEvent = false,
    this.customerRef,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': this.title,
      'address': this.location,
      'customer': this.customer,
      'phonenumber': this.phoneNumber,
      'startDate': dateStringVerbose(start),
      'endDate': dateStringVerbose(end),
      'anteckning': this.notes,
      'persons': persons?.map((e) => e.id).toList(),
      'images': originalImageStoragePaths,
      'customerKey': this.customerKey,
      'customerContactIndex': this.customerContactIndex,
      'timereported': this.timereported,
      'eventType': eventType.toString(),
      'workCategoryId': this.workCategoryId,
      'contactKey': this.contactKey
    };
  }

  Event copyWith({Color? color, DateTime? start, DateTime? end, bool? isMovingEvent}) {
    return Event(
        id: this.id,
        start: start ?? this.start,
        end: end ?? this.end,
        title: this.title,
        eventType: this.eventType,
        persons: this.persons,
        color: color ?? this.color,
        customer: this.customer,
        location: this.location,
        phoneNumber: this.phoneNumber,
        notes: this.notes,
        imageStoragePaths: this.imageStoragePaths,
        originalImageStoragePaths: this.originalImageStoragePaths,
        customerKey: this.customerKey,
        customerContactIndex: this.customerContactIndex,
        timereported: this.timereported,
        workCategoryId: this.workCategoryId,
        contactKey: this.contactKey,
        isMovingEvent: isMovingEvent ?? false);
  }
}
