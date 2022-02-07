import 'package:flutter/material.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/event_type.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import 'package:zimple/widgets/provider_widget.dart';

import '../utils/date_utils.dart';
import '../utils/weekday_to_string.dart';

class Timeplan extends StatelessWidget {
  final EventManager eventManager;
  final Function(Event) didTapEvent;
  final bool appBarEnabled;
  final bool shouldShowIsTimereported;
  final String? userIdToOnlyShow;
  Timeplan(
      {required this.eventManager,
      required this.didTapEvent,
      this.appBarEnabled = true,
      this.shouldShowIsTimereported = false,
      this.userIdToOnlyShow});
  final DateTime today = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarEnabled
          ? PreferredSize(
              preferredSize: Size.fromHeight(75.0),
              child: AppBarWidget(
                hasMenu: true,
                title: "Tidsplan",
              ))
          : null,
      body: Container(
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
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
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      : Container(),
                  TimeplanDay(
                    date: date,
                    eventManager: this.eventManager,
                    didTapEvent: didTapEvent,
                    shouldShowIsTimereported: shouldShowIsTimereported,
                    userIdToOnlyShow: userIdToOnlyShow,
                  ),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(
              color: Colors.grey.withOpacity(0.5),
              indent: 15.0,
              endIndent: 15.0,
              height: 0.5,
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
  final Function(Event) didTapEvent;
  final bool shouldShowIsTimereported;
  final String? userIdToOnlyShow;

  TimeplanDay(
      {required this.eventManager,
      required this.date,
      required this.didTapEvent,
      this.shouldShowIsTimereported = false,
      this.userIdToOnlyShow});

  List<Event> _filterForUserIfShould() {
    var events = eventManager.getEventsByDate(date, eventFilter: eventManager.eventFilter);
    if (userIdToOnlyShow != null) {
      return events.where((event) => event.persons?.any((person) => person.id == userIdToOnlyShow) ?? false).toList();
    } else {
      return events;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isToday = isToday(date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isToday ? Colors.red : Colors.transparent,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(_isToday ? 8.0 : 0.0),
                    child: Text(dateFormat.format(date),
                        style: TextStyle(
                            fontSize: _isToday ? 20 : 25.0,
                            fontWeight: FontWeight.w900,
                            color: isToday(date) ? Colors.white : null)),
                  ),
                ),
                Text(dateToAbbreviatedString(date), style: TextStyle(color: _isToday ? Colors.red : null))
              ],
            ),
            SizedBox(width: 20.0),
            TimeplanEvent(
              events: _filterForUserIfShould(),
              didTapEvent: didTapEvent,
              shouldShowIsTimereported: shouldShowIsTimereported,
              userIdToOnlyShow: userIdToOnlyShow,
            )
          ],
        ),
      ),
    );
  }
}

class TimeplanEvent extends StatelessWidget {
  final List<Event> events;
  final Function(Event) didTapEvent;
  final bool shouldShowIsTimereported;
  final String? userIdToOnlyShow;

  TimeplanEvent({required this.events, required this.didTapEvent, required this.shouldShowIsTimereported, this.userIdToOnlyShow});

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
              didTapEvent(event);
            },
            child: TimeplanEventContainer(event, shouldShowIsTimereported),
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

class TimeplanEventContainer extends StatelessWidget {
  final Event event;
  final bool shouldShowIsTimereported;
  TimeplanEventContainer(this.event, this.shouldShowIsTimereported);

  Color _dynamicBlackWhite(Color color) {
    return color.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  }

  bool _shouldShowTimereported(String userToken) {
    if (shouldShowIsTimereported) {
      var timereported = event.timereported ?? [];
      return timereported.contains(userToken);
    }
    return false;
  }

  Widget _buildTimereportedSection(String userToken) {
    return _shouldShowTimereported(userToken)
        ? Row(
            children: [
              CircleAvatar(backgroundColor: Colors.white, radius: 10, child: Icon(Icons.check, size: 14, color: green)),
              SizedBox(
                width: 5.0,
              ),
              Text("Tidrapporterat", style: TextStyle(color: _dynamicBlackWhite(event.color)))
            ],
          )
        : Container();
  }

  String buildCustomerLocation() {
    String agg = "";
    if (event.customer.isNotBlank()) {
      agg += event.customer! + ", ";
    }
    if (event.location.isNotBlank()) {
      agg += event.location!;
    }
    return agg;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context, listen: true).isDarkMode();
    var userToken = Provider.of<ManagerProvider>(context, listen: false).user.token;
    return Container(
      decoration: BoxDecoration(
          color: _shouldShowTimereported(userToken) ? event.color.withAlpha(120) : event.color,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: !isDarkMode
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(-2, 2), // changes position of shadow
                  ),
                ]
              : null),
      child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 75),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: _dynamicBlackWhite(event.color))),
                SizedBox(height: 4.0),
                buildTimeRow(),
                SizedBox(height: 4.0),
                event.persons != null ? ListPersonCircleAvatar(persons: event.persons!, radius: 8, spacing: 2) : Container(),
                SizedBox(height: 4.0),
                event.location.isNotBlank()
                    ? Text(
                        buildCustomerLocation(),
                        style: TextStyle(color: _dynamicBlackWhite(event.color)),
                      )
                    : Container(),
                SizedBox(height: 5.0),
                _buildTimereportedSection(userToken)
              ],
            ),
          )),
    );
  }

  Widget buildTimeRow() {
    if (event.eventType == EventType.vacation) {
      return Container();
    }
    return Row(
      children: [
        Text(dateToHourMinute(event.start) + " - " + dateToHourMinute(event.end),
            style: TextStyle(color: _dynamicBlackWhite(event.color)))
      ],
    );
  }
}
