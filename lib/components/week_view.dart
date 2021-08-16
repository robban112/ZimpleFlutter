import 'dart:async';

import 'package:zimple/utils/date_utils.dart';
import 'package:flutter/material.dart';
import '../model/event.dart';
import 'vertical_time_container.dart';
import 'week_header.dart';
import '../managers/event_layout_manager.dart';
import '../utils/date_utils.dart';
import 'package:zimple/utils/constants.dart';

class WeekView extends StatelessWidget {
  WeekView(
      {required int numberOfDays,
      required double minuteHeight,
      required this.events,
      required this.didTapEvent,
      required this.dates,
      required this.didTapHour,
      required this.didDoubleTapHour})
      : _numberOfDays = numberOfDays,
        _minuteHeight = minuteHeight;

  final int _numberOfDays;
  final double _minuteHeight;
  final List<Event> events;
  final List<DateTime> dates;
  final Function(Event) didTapEvent;
  final Function(DateTime, int) didTapHour;
  final Function(DateTime, int) didDoubleTapHour;

  final double verticalTimeContainerWidth = 45;

  bool _isCurrentWeek() {
    if (dates.length > 0) {
      return dates.any((date) => isCurrentWeek(date));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var dayWidth =
        (MediaQuery.of(context).size.width - verticalTimeContainerWidth) /
            _numberOfDays;
    var eventLayoutManager = EventLayoutManager(
        dayWidth: dayWidth,
        events: events,
        minuteHeight: _minuteHeight,
        datesOfWeek: dates,
        didTapEvent: didTapEvent);
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: primaryColor),
      child: Column(
        children: <Widget>[
          WeekHeader(
            dates: dates,
            numberOfDays: _numberOfDays,
            leftPadding: verticalTimeContainerWidth,
            dayWidth: dayWidth,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      VerticalTimeContainer(
                        width: verticalTimeContainerWidth,
                        minuteHeight: _minuteHeight,
                      ),
                      Row(
                        children: _buildHoursAndEvents(
                            context, dates, eventLayoutManager, dayWidth),
                      ),
                    ],
                  ),
                  _isCurrentWeek()
                      ? CurrentTimeLine(
                          minuteHeight: this._minuteHeight,
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHoursAndEvents(BuildContext context, List<DateTime> dates,
      EventLayoutManager eventLayoutManager, double dayWidth) {
    return List.generate(_numberOfDays, (index) {
      List<Widget> events = eventLayoutManager.buildEventContainers(index);
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    width: 0.2, color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
                children: _buildHourContainer(context, dates[index], dayWidth)),
          ),
          if (events.isNotEmpty)
            Stack(
              children: events,
            ),
        ],
      );
    });
  }

  List<Widget> _buildHourContainer(
      BuildContext context, DateTime date, double dayWidth) {
    return List.generate(
      24,
      (index) => GestureDetector(
        onTap: () {
          didTapHour(date, index);
        },
        onDoubleTap: () {
          this.didDoubleTapHour(date, index);
        },
        child: HourContainer(
          minuteHeight: _minuteHeight,
          dayWidth: dayWidth,
          color: isToday(date)
              ? Color.alphaBlend(
                  Theme.of(context).accentColor.withOpacity(0.15),
                  Theme.of(context).backgroundColor)
              : Theme.of(context).backgroundColor,
        ),
      ),
    );
  }
}

class HourContainer extends StatelessWidget {
  final double minuteHeight;
  final double dayWidth;
  final Color color;
  HourContainer({
    required this.minuteHeight,
    required this.dayWidth,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * minuteHeight,
      width: dayWidth - 0.2,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.2, color: Theme.of(context).dividerColor),
        ),
        color: color,
      ),
    );
  }
}

class CurrentTimeLine extends StatefulWidget {
  final double minuteHeight;
  CurrentTimeLine({required this.minuteHeight});
  @override
  _CurrentTimeLineState createState() => _CurrentTimeLineState();
}

class _CurrentTimeLineState extends State<CurrentTimeLine> {
  var currentDay = DateTime.now();
  var now = DateTime.now();
  Timer? timer;
  @override
  void initState() {
    super.initState();

    print("Initiating current time line");
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (!mounted) return;
      setState(() {
        print("Updating current time line");
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  double _getTopPadding() {
    var padding = (now.hour * 60 + now.minute) * widget.minuteHeight - 8;
    return padding > 0 ? padding : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _getTopPadding()),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              dateToHourMinute(now),
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: Container(
              height: 1.0,
              decoration: const BoxDecoration(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
