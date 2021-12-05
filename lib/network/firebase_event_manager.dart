import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/absence_request.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/event_type.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/utils/date_utils.dart';

class FirebaseEventManager {
  String company;
  PersonManager personManager;
  CustomerManager customerManager;
  late fb.DatabaseReference eventRef;
  late fb.DatabaseReference database;

  FirebaseEventManager({
    required this.company,
    required this.personManager,
    required this.customerManager,
  }) {
    this.database = fb.FirebaseDatabase.instance.reference();
    this.eventRef = database.reference().child(company).child('Events');
  }

  Future<void> changeEvent(Event event) {
    return eventRef.child(event.id).update(event.toJson()).then((value) => value);
  }

  fb.DatabaseReference newEventRef() {
    return eventRef.push();
  }

  Future<String> addEventWithRef(fb.DatabaseReference ref, Event event) {
    return ref.set(event.toJson()).then((value) => ref.key);
  }

  Future<String> addEvent(Event event) {
    fb.DatabaseReference ref = eventRef.push();
    return ref.set(event.toJson()).then((value) => ref.key);
  }

  Future<void> removeEvent(Event event) {
    return eventRef.child(event.id).remove().then((value) => value);
  }

  Future<void> removeEventsIds(List<String> eventIds) async {
    eventIds.forEach((id) async {
      await eventRef.child(id).remove();
    });
  }

  Stream<EventManager> listenEvents() {
    return eventRef.limitToLast(1000).onValue.map((event) {
      print("Listening events");
      var snapshot = event.snapshot;
      return EventManager(events: _mapSnapshot(snapshot));
      //return _mapSnapshot(snapshot);
    });
  }

  Future<List<Event>> getEvents() async {
    var snapshot = await eventRef.limitToLast(500).once();
    return _mapSnapshot(snapshot);
  }

  Future<List<String>> addVacationPeriod(AbsenceRequest absenceRequest, String? name) async {
    List<DateTime> dates = getDaysInBetween(absenceRequest.startDate, absenceRequest.endDate);
    List<String> eventIds = [];
    for (DateTime date in dates) {
      DateTime _startDate = DateTime.utc(date.year, date.month, date.day, 00, 0, 0);
      DateTime _endDate = DateTime.utc(date.year, date.month, date.day, 2, 0, 0);
      Event event = Event(
          id: "",
          start: _startDate,
          end: _endDate,
          title: "${absenceToString(absenceRequest.absenceType)} - ${name ?? ""}",
          notes: absenceRequest.notes,
          persons: [
            Person(id: absenceRequest.userId, color: Colors.white, name: ""),
          ],
          eventType: EventType.vacation);
      String id = await addEvent(event);
      eventIds.add(id);
    }
    return eventIds;
  }

  List<Event> _mapSnapshot(fb.DataSnapshot snapshot) {
    List<Event> events = [];
    if (snapshot.value == null) {
      return [];
    }
    Map<String, dynamic>? mapOfMaps = Map.from(snapshot.value);
    if (mapOfMaps == null) {
      return [];
    }
    for (String key in mapOfMaps.keys) {
      dynamic eventData = mapOfMaps[key];
      DateTime startDate = DateTime.parse(eventData['startDate']);
      DateTime endDate = DateTime.parse(eventData['endDate']);
      String title = eventData['title'] != null ? eventData['title'] : "";
      String? notes = eventData['anteckning'];
      String? customer = eventData['customer'];
      String? location = eventData['address'];
      String? phoneNumber = eventData['phonenumber'];
      String? customerKey = eventData["customerKey"];
      Customer? customerRef;
      if (customerKey != null) {
        customerRef = this.customerManager.getCustomer(customerKey);
      }
      String? contactKey = eventData["contactKey"];
      EventType eventType = stringToEventType(eventData['eventType']);
      int? customerContactIndex = eventData['customerContactIndex'];
      int? workCategoryId = eventData['workCategoryId'];
      List<String> timereported = _getTimereported(eventData) ?? [];
      List<String> imageStoragePaths = _getImagesFromEventData(eventData) ?? [];
      List<Person> persons = _getPersonsFromEventData(eventData);
      Color eventColor = _setEventColorFromPersons(persons);
      Map<String, dynamic>? imageMap = eventData['images'] == null ? null : Map.from(eventData['images']);
      Event event = Event(
        end: endDate,
        start: startDate,
        id: key,
        eventType: eventType,
        title: title,
        persons: persons,
        color: eventColor,
        notes: notes,
        customer: customer,
        location: location,
        phoneNumber: phoneNumber,
        imageStoragePaths: imageStoragePaths,
        originalImageStoragePaths: imageMap,
        customerKey: customerKey,
        customerContactIndex: customerContactIndex,
        timereported: timereported,
        workCategoryId: workCategoryId,
        contactKey: contactKey,
        customerRef: customerRef,
      );
      events.add(event);
    }
    return events;
  }

  List<String>? _getImagesFromEventData(dynamic eventData) {
    dynamic imageData = eventData['images'];
    if (imageData == null) {
      return null;
    }
    Map<String, dynamic> imageMap = Map.from(imageData);
    var imageKeys = imageMap.keys;
    List<String> storagePaths = imageKeys.map((key) => imageMap[key]['storagePath'].toString()).toList();
    return storagePaths;
  }

  List<Person> _getPersonsFromEventData(dynamic eventData) {
    List<Person> persons = [];
    if (eventData['persons'] != null) {
      List<dynamic> personList = List.from(eventData['persons']);
      var p = personList.map((e) => e.toString()).toList();
      persons = personManager.getPersonsByIds(p);
    }
    return persons;
  }

  Color _setEventColorFromPersons(List<Person> persons) {
    if (persons.length == 0) {
      return Colors.orange;
    } else if (persons.length == 1) {
      return persons[0].color;
    } else {
      persons.sort((a, b) => a.id.compareTo(b.id));
      HSVColor? colorAggregator = HSVColor.fromColor(persons[0].color);
      for (var person in persons) {
        colorAggregator = HSVColor.lerp(colorAggregator, HSVColor.fromColor(person.color), 0.5);
      }
      //return persons[1].color;
      return colorAggregator?.toColor() ?? Colors.blue;
    }
  }

  List<String>? _getTimereported(dynamic eventData) {
    if (eventData['timereported'] == null) {
      return null;
    }
    return List.from(eventData['timereported']).map((e) => e.toString()).toList();
  }
}
