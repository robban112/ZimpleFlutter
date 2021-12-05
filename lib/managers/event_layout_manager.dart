import 'package:zimple/model/event_layout.dart';
import 'package:flutter/material.dart';
import 'package:zimple/model/event_type.dart';
import '../components/event_container.dart';
import '../model/event.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/iterables.dart';
import '../utils/date_utils.dart';

class EventLayoutManager {
  final double dayWidth;
  final List<Event> events;
  final double minuteHeight;
  final List<DateTime> datesOfWeek;
  final Function(Event) didTapEvent;
  final Function(Event) didLongPressEvent;
  EventLayoutManager({
    required this.dayWidth,
    required this.events,
    required this.minuteHeight,
    required this.datesOfWeek,
    required this.didTapEvent,
    required this.didLongPressEvent,
  });

  List<Widget> buildEventContainers(int index) {
    //List<EventLayout> eventContainers = [];
    int firstDay = datesOfWeek.first.weekday;
    List<Event> eventsOfDay = events.where((event) => event.start.weekday - 1 == index + firstDay - 1).toList();
    for (int indexEvent = 0; indexEvent < eventsOfDay.length; indexEvent++) {
      Event event = eventsOfDay[indexEvent];
      if (!event.start.isSameDate(event.end)) {
        event.end = DateTime(event.start.year, event.start.month, event.start.day, event.end.hour, event.end.minute);
      }
      int diffHour = event.end.difference(event.start).inHours;
      int diffMin = event.end.difference(event.start).inMinutes;
      double height = (diffHour + (diffMin - 60 * diffHour) / 60) * minuteHeight * 60;
      double top = event.start.hour * minuteHeight * 60;
      top += event.start.minute * minuteHeight;

      // if (event.eventType == EventType.vacation) {
      //   top = 0;
      // }

      EventLayout eventLayout = EventLayout(height: height, width: dayWidth, left: 0, top: top);
      event.layout = eventLayout;
      //eventContainers.add(eventContainer);
    }
    List<Widget> columnBasedLayout = _columnBasedLayout(eventsOfDay)
        .map((event) => EventContainer(
              event: event,
              eventLayout: event.layout,
              didTapEvent: didTapEvent,
              didLongPressEvent: didLongPressEvent,
            ))
        .toList();

    return columnBasedLayout;
  }

  List<Event> _columnBasedLayout(List<Event> sectionItemContainers) {
    if (sectionItemContainers.isEmpty) {
      return [];
    }
    var firstItem = sectionItemContainers.first;
    List<List<Event>> groupedEvents = [];
    groupedEvents.add([firstItem]);
    for (int index = 1; index < sectionItemContainers.length; index++) {
      Event item = sectionItemContainers[index];
      Tuple2<bool, int> canBePlacedBeneath = _canBePlacedBeneath(item, groupedEvents);
      bool placedBeneath = canBePlacedBeneath.item1;
      int beneathColumnNumber = canBePlacedBeneath.item2;
      if (placedBeneath) {
        groupedEvents[beneathColumnNumber].add(item);
      } else {
        groupedEvents.add([item]);
      }
    }

    double columnWidth = dayWidth / groupedEvents.length;
    int adjust = 0;

    for (List<Event> column in groupedEvents) {
      for (Event eventContainer in column) {
        eventContainer.layout.width = columnWidth;
        eventContainer.layout.left = adjust * columnWidth;
      }
      adjust += 1;
    }
    List<List<Event>> extendedGroupedEvents = _extendGroupedEvents(groupedEvents, columnWidth);
    return _groupedEventsToList(extendedGroupedEvents);
  }

  List<Event> _groupedEventsToList(List<List<Event>> groupedEvents) {
    List<Event> eventContainers = [];
    for (List<Event> column in groupedEvents) {
      for (Event eventContainer in column) {
        eventContainers.add(eventContainer);
      }
    }
    return eventContainers;
  }

  Tuple2<bool, int> _canBePlacedBeneath(Event item, List<List<Event>> groupedEvents) {
    for (var index = 0; index < groupedEvents.length; index++) {
      List<Event> column = groupedEvents[index];
      var lastItem = column.last;
      var lastItemMaxY = lastItem.layout.top + lastItem.layout.height;
      var itemMinY = item.layout.top;
      if (lastItemMaxY <= itemMinY) {
        return Tuple2(true, index);
      }
    }
    return Tuple2(false, 0);
  }

  bool _canExtendToColumn(Event item, List<Event> column) {
    if (column.isEmpty) {
      return true;
    }
    double start = item.layout.top;
    double end = start + item.layout.height;
    if (end <= column.first.layout.top) {
      return true;
    } else if (start >= (column.last.layout.top + column.last.layout.height)) {
      return true;
    }
    return false;
  }

  List<List<Event>> _extendGroupedEvents(List<List<Event>> groupedEvents, double width) {
    for (int index = 0; index < groupedEvents.length; index++) {
      for (Event eventContainer in groupedEvents[index]) {
        double adjustWidthMultiplier = 1.0;
        for (int followingIndex = index + 1; followingIndex < groupedEvents.length; followingIndex++) {
          if (_canExtendToColumn(eventContainer, groupedEvents[followingIndex])) {
            adjustWidthMultiplier += 1;
          } else {
            break;
          }
        }
        eventContainer.layout.width = width * adjustWidthMultiplier;
      }
    }
    return groupedEvents;
  }

  bool isOverlapping(Event firstEvent, Event secondEvent) {
    var firstBottom = firstEvent.layout.top + firstEvent.layout.height;
    var secondBottom = secondEvent.layout.top + secondEvent.layout.height;
    if (firstBottom < secondBottom && secondEvent.layout.top > firstBottom) {
      return true;
    } else if (secondBottom < firstBottom && firstEvent.layout.top > secondBottom) {
      return true;
    }
    return false;
  }
}
