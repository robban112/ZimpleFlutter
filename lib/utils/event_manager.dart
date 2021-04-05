import 'package:flutter/material.dart';
import '../model/event.dart';
import '../utils/date_utils.dart';

class EventManager {
  List<Event> events;
  Map<String, List<Event>> eventMap = Map<String, List<Event>>();

  EventManager({@required this.events}) {
    orderEventByWeek(this.events);
  }

  void setEvents(List<Event> events) {
    this.eventMap = {};
    this.events = events;
    orderEventByWeek(events);
  }

  void orderEventByWeek(List<Event> events) {
    events.forEach((event) {
      String dateKey = eventMapKey(event.start);
      if (!eventMap.containsKey(dateKey)) {
        eventMap[dateKey] = [event];
      } else {
        eventMap[dateKey].add(event);
      }
    });
  }

  List<Event> getEventByWeekIndex(int weekIndex, int daysMultiplier) {
    var then = DateTime.now().add(Duration(days: daysMultiplier * weekIndex));
    var weekKey = eventMapKey(then);

    if (eventMap.containsKey(weekKey)) {
      return sortEventByStartDate(eventMap[weekKey]);
    }
    return [];
  }

  List<Event> getEventsByDate(DateTime date) {
    var key = eventMapKey(date);
    if (eventMap.containsKey(key)) {
      return sortEventByStartDate(eventMap[key]);
    }
    return [];
  }

  List<Event> getEventByStartDate(DateTime date, int daysForward) {
    var dateStr = dateString(date);
    //print("date: $dateStr, daysForward: $daysForward");
    List<Event> events = [];
    for (var i = 0; i < daysForward; i++) {
      events += getEventsByDate(date.add(Duration(days: i)));
    }
    return events;
  }

  List<Event> sortEventByStartDate(List<Event> events) {
    events.sort((a, b) => a.start.compareTo(b.start));
    return events;
  }

  String eventMapKey(DateTime date) {
    // int week = weekNumber(date);
    // String year = yearString(date);
    // return year + week.toString();
    return dateString(date);
  }
}
