import 'package:flutter/material.dart';
import '../model/event.dart';
import '../utils/date_utils.dart';

class EventManager {
  List<Event> events;
  List<Event> Function(List<Event>)? eventFilter;

  Map<String, List<Event>> eventMap = Map<String, List<Event>>();
  Map<String, Event> eventKeyMap = Map<String, Event>();

  EventManager({required this.events}) {
    orderEventByWeek(this.events);
  }

  void setEvents(List<Event> events) {
    this.eventMap = {};
    this.events = events;
    orderEventByWeek(events);
  }

  void orderEventByWeek(List<Event> events) {
    events.forEach((event) {
      eventKeyMap[event.id] = event;
      String dateKey = eventMapKey(event.start);
      if (!eventMap.containsKey(dateKey))
        eventMap[dateKey] = [event];
      else
        eventMap[dateKey]?.add(event);
    });
  }

  List<Event> getEventByWeekIndex(int weekIndex, int daysMultiplier) {
    var then = DateTime.now().add(Duration(days: daysMultiplier * weekIndex));
    var weekKey = eventMapKey(then);

    if (eventMap.containsKey(weekKey))
      return sortEventByStartDate(eventMap[weekKey]!);
    else
      return [];
  }

  List<Event> getEventsByDate(DateTime date) {
    var key = eventMapKey(date);
    if (eventMap.containsKey(key)) {
      var sortedEvents = sortEventByStartDate(eventMap[key]!);
      if (eventFilter != null)
        return eventFilter!(sortedEvents);
      else
        return sortedEvents;
    }
    return [];
  }

  List<Event> getEventByStartDate(DateTime date, int daysForward) {
    List<Event> events = [];
    for (var i = 0; i < daysForward; i++) events += getEventsByDate(date.add(Duration(days: i)));

    return events;
  }

  List<Event> sortEventByStartDate(List<Event> events) {
    events.sort((a, b) => a.start.compareTo(b.start));
    return events;
  }

  String eventMapKey(DateTime date) => dateString(date);

  Event? getEventForKey({String? key}) {
    if (key == null) return null;
    return eventKeyMap[key];
  }

  void updateEvent({required String key, required Event newEvent}) {
    Event? savedEvent = eventKeyMap[key];
    if (savedEvent == null) return;

    savedEvent.color = newEvent.color;
    savedEvent.start = newEvent.start;
    savedEvent.end = newEvent.end;
    savedEvent.isMovingEvent = newEvent.isMovingEvent;
  }

  bool hasUserTimreportedCurrentEvent(Event event, String key) {
    return event.timereported?.contains(key) ?? false;
  }
}
