import 'package:zimple/model/event_layout.dart';
import 'package:flutter/material.dart';
import '../components/event_container.dart';
import '../model/event.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/iterables.dart';
import 'date_utils.dart';

class EventLayoutManager {
  final double dayWidth;
  final List<Event> events;
  final double minuteHeight;
  final List<DateTime> datesOfWeek;
  final Function(Event) didTapEvent;
  EventLayoutManager(
      {required this.dayWidth,
      required this.events,
      required this.minuteHeight,
      required this.datesOfWeek,
      required this.didTapEvent});

  List<Widget> buildEventContainers(int index) {
    List<EventLayout> eventContainers = [];
    var firstDay = datesOfWeek.first.weekday;
    List<Event> eventsOfDay = events
        .where((event) => event.start.weekday - 1 == index + firstDay - 1)
        .toList();
    for (var index_event = 0; index_event < eventsOfDay.length; index_event++) {
      Event event = eventsOfDay[index_event];
      if (!event.start.isSameDate(event.end)) {
        event.end = DateTime(event.start.year, event.start.month,
            event.start.day, event.end.hour, event.end.minute);
      }
      int diffHour = event.end.difference(event.start).inHours;
      int diffMin = event.end.difference(event.start).inMinutes;
      //print(diffMin);
      double height =
          (diffHour + (diffMin - 60 * diffHour) / 60) * minuteHeight * 60;
      double top = event.start.hour * minuteHeight * 60;
      top += event.start.minute * minuteHeight;
      // print('height: $height');
      // print('top: $top');
      EventLayout eventContainer =
          EventLayout(height: height, width: dayWidth, left: 0, top: top);
      eventContainers.add(eventContainer);
    }

    List<Widget> columnBasedLayout =
        zip([_columnBasedLayout(eventContainers), eventsOfDay])
            .map((zipped) => EventContainer(
                  event: zipped[1] as Event,
                  eventLayout: zipped[0] as EventLayout,
                  didTapEvent: didTapEvent,
                ))
            .toList();

    return columnBasedLayout;
  }

  Widget _mapToEventContainer(Event event, EventLayout eventLayout) {
    return EventContainer(
      event: event,
      eventLayout: eventLayout,
      didTapEvent: didTapEvent,
    );
  }

  List<EventLayout> _columnBasedLayout(
      List<EventLayout> sectionItemContainers) {
    if (sectionItemContainers.length == 0) {
      return sectionItemContainers;
    }
    var firstItem = sectionItemContainers.first;
    List<List<EventLayout>> groupedEvents = [];
    groupedEvents.add([firstItem]);
    for (var index = 1; index < sectionItemContainers.length; index++) {
      var item = sectionItemContainers[index];
      Tuple2<bool, int> canBePlacedBeneath =
          _canBePlacedBeneath(item, groupedEvents);
      bool placedBeneath = canBePlacedBeneath.item1;
      int beneathColumnNumber = canBePlacedBeneath.item2;
      if (placedBeneath) {
        groupedEvents[beneathColumnNumber].add(item);
      } else {
        groupedEvents.add([item]);
      }
    }

    var columnWidth = dayWidth / groupedEvents.length;
    var adjust = 0;

    for (List<EventLayout> column in groupedEvents) {
      for (EventLayout eventContainer in column) {
        eventContainer.width = columnWidth;
        eventContainer.left = adjust * columnWidth;
      }
      adjust += 1;
    }
    var extendedGroupedEvents =
        _extendGroupedEvents(groupedEvents, columnWidth);
    return _groupedEventsToList(extendedGroupedEvents);
  }

  List<EventLayout> _groupedEventsToList(
      List<List<EventLayout>> groupedEvents) {
    List<EventLayout> eventContainers = [];
    for (List<EventLayout> column in groupedEvents) {
      for (EventLayout eventContainer in column) {
        eventContainers.add(eventContainer);
      }
    }
    return eventContainers;
  }

  Tuple2<bool, int> _canBePlacedBeneath(
      EventLayout item, List<List<EventLayout>> groupedEvents) {
    for (var index = 0; index < groupedEvents.length; index++) {
      List<EventLayout> column = groupedEvents[index];
      var lastItem = column.last;
      var lastItemMaxY = lastItem.top + lastItem.height;
      var itemMinY = item.top;
      if (lastItemMaxY <= itemMinY) {
        return Tuple2(true, index);
      }
    }
    return Tuple2(false, 0);
  }

  bool _canExtendToColumn(EventLayout item, List<EventLayout> column) {
    if (column.length == 0) {
      return true;
    }
    var start = item.top;
    var end = start + item.height;
    if (end <= column.first.top) {
      return true;
    } else if (start >= (column.last.top + column.last.height)) {
      return true;
    }
    return false;
  }

  List<List<EventLayout>> _extendGroupedEvents(
      List<List<EventLayout>> groupedEvents, double width) {
    for (var index = 0; index < groupedEvents.length; index++) {
      for (EventLayout eventContainer in groupedEvents[index]) {
        var adjustWidthMultiplier = 1.0;
        for (var following_index = index + 1;
            following_index < groupedEvents.length;
            following_index++) {
          if (_canExtendToColumn(
              eventContainer, groupedEvents[following_index])) {
            adjustWidthMultiplier += 1;
          } else {
            break;
          }
        }
        eventContainer.width = width * adjustWidthMultiplier;
      }
    }
    return groupedEvents;
  }

  bool isOverlapping(EventLayout firstEvent, EventLayout secondEvent) {
    var firstBottom = firstEvent.top + firstEvent.height;
    var secondBottom = secondEvent.top + secondEvent.height;
    if (firstBottom < secondBottom && secondEvent.top > firstBottom) {
      return true;
    } else if (secondBottom < firstBottom && firstEvent.top > secondBottom) {
      return true;
    }
    return false;
  }
}
