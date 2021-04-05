import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/utils/event_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../utils/date_utils.dart';
import '../utils/weekday_to_string.dart';
import 'package:zimple/utils/constants.dart';

class Timeplan extends StatelessWidget {
  final EventManager eventManager;
  final Function(Event) didTapEvent;
  Timeplan({@required this.eventManager, this.didTapEvent});
  final DateTime today = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.0),
          child: AppBarWidget(
            title: "Tidsplan",
          )),
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: InfiniteListView.separated(
            //controller: _infiniteController,
            itemBuilder: (BuildContext context, int index) {
              var date = today.add(Duration(days: index));
              return Column(
                children: [
                  isFirstDayOfMonth(date)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(dateStringMonth(date),
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.normal)),
                        )
                      : Container(),
                  TimeplanDay(
                    date: date,
                    eventManager: this.eventManager,
                  ),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              indent: 15.0,
              endIndent: 15.0,
              height: 1.0,
            ),
            anchor: 0.5,
          )),
    );
  }
}

class TimeplanDay extends StatelessWidget {
  final EventManager eventManager;
  final DateTime date;
  final DateFormat dateFormat = DateFormat(DateFormat.DAY, locale);

  TimeplanDay({@required this.eventManager, @required this.date});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 35.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateFormat.format(date),
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.normal,
                          color:
                              isToday(date) ? Colors.lightBlue : Colors.black)),
                  Text(dateToAbbreviatedString(date),
                      style: TextStyle(
                          color:
                              isToday(date) ? Colors.lightBlue : Colors.black))
                ],
              ),
            ),
            SizedBox(width: 20.0),
            TimeplanEvent(events: eventManager.getEventsByDate(date))
          ],
        ),
      ),
    );
  }
}

class TimeplanEvent extends StatelessWidget {
  final List<Event> events;
  TimeplanEvent({this.events});

  Color _dynamicBlackWhite(Color color) {
    return color.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var event = events[index];
          return GestureDetector(
            onTap: () {
              ProviderWidget.of(context).didTapEvent(event);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: event.color, borderRadius: BorderRadius.circular(8.0)),
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 75),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title,
                            style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.normal,
                                color: _dynamicBlackWhite(event.color))),
                        SizedBox(height: 2.0),
                        Row(
                          children: [
                            Text(
                                dateToHourMinute(event.start) +
                                    " - " +
                                    dateToHourMinute(event.end),
                                style: TextStyle(
                                    color: _dynamicBlackWhite(event.color)))
                          ],
                        ),
                        SizedBox(height: 2.0),
                        Text(
                          event.location,
                          style:
                              TextStyle(color: _dynamicBlackWhite(event.color)),
                        ),
                      ],
                    ),
                  )),
            ),
          );
        },
        itemCount: events.length,
        separatorBuilder: (contex, index) {
          return SizedBox(height: 8.0);
        },
      ),
    );
  }
}
