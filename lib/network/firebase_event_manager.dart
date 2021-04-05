import 'package:zimple/utils/event_manager.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import '../model/person.dart';
import '../model/event.dart';
import '../utils/person_manager.dart';

class FirebaseEventManager {
  String company;
  PersonManager personManager;
  fb.DatabaseReference eventRef;
  fb.DatabaseReference database;

  FirebaseEventManager({@required this.company, @required this.personManager}) {
    database = fb.FirebaseDatabase.instance.reference();
    eventRef = database.reference().child(company).child('Events');
  }

  Future<void> changeEvent(Event event) {
    return eventRef
        .child(event.id)
        .update(event.toJson())
        .then((value) => value);
  }

  Future<void> addEvent(Event event) {
    return eventRef.push().set(event.toJson()).then((value) => value);
  }

  Future<void> removeEvent(Event event) {
    return eventRef.child(event.id).remove().then((value) => value);
  }

  Stream<EventManager> listenEvents() {
    return eventRef.limitToLast(500).onValue.map((event) {
      var snapshot = event.snapshot;
      return EventManager(events: _mapSnapshot(snapshot));
      //return _mapSnapshot(snapshot);
    });
  }

  Future<List<Event>> getEvents() async {
    var snapshot = await eventRef.limitToLast(500).once();
    return _mapSnapshot(snapshot);
  }

  List<Event> _mapSnapshot(fb.DataSnapshot snapshot) {
    List<Event> events = [];
    if (snapshot.value == null) {
      return [];
    }
    Map<String, dynamic> mapOfMaps = Map.from(snapshot.value);
    if (mapOfMaps == null) {
      return [];
    }
    for (String key in mapOfMaps.keys) {
      dynamic eventData = mapOfMaps[key];
      DateTime startDate = DateTime.parse(eventData['startDate']);
      DateTime endDate = DateTime.parse(eventData['endDate']);
      String title = eventData['title'] != null ? eventData['title'] : "";
      String notes =
          eventData['anteckning'] != null ? eventData['anteckning'] : "";
      String customer =
          eventData['customer'] != null ? eventData['customer'] : "";
      String location =
          eventData['address'] != null ? eventData['address'] : "";
      String phoneNumber =
          eventData['phoneNumber'] != null ? eventData['phoneNumber'] : "";

      List<String> imageStoragePaths = _getImagesFromEventData(eventData);
      List<Person> persons = _getPersonsFromEventData(eventData);
      Color eventColor = _setEventColorFromPersons(persons);
      Map<String, dynamic> imageMap =
          eventData['images'] == null ? null : Map.from(eventData['images']);
      Event event = Event(
          end: endDate,
          start: startDate,
          id: key,
          title: title,
          persons: persons,
          color: eventColor,
          notes: notes,
          customer: customer,
          location: location,
          phoneNumber: phoneNumber,
          imageStoragePaths: imageStoragePaths,
          originalImageStoragePaths: imageMap);
      events.add(event);
    }
    return events;
  }

  List<String> _getImagesFromEventData(dynamic eventData) {
    dynamic imageData = eventData['images'];
    if (imageData == null) {
      return null;
    }
    Map<String, dynamic> imageMap = Map.from(imageData);
    var imageKeys = imageMap?.keys;
    List<String> storagePaths = imageKeys
        ?.map((key) => imageMap[key]['storagePath'].toString())
        ?.toList();
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
      HSVColor colorAggregator = HSVColor.fromColor(persons[0].color);
      for (var person in persons) {
        colorAggregator = HSVColor.lerp(
            colorAggregator, HSVColor.fromColor(person.color), 0.5);
      }
      //return persons[1].color;
      return colorAggregator.toColor();
    }
  }
}
