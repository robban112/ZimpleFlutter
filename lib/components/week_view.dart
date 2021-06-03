import 'dart:async';

import 'package:zimple/utils/date_utils.dart';
import 'package:flutter/material.dart';
import '../model/event.dart';
import 'vertical_time_container.dart';
import 'week_header.dart';
import '../utils/event_layout_manager.dart';
import '../utils/date_utils.dart';
import 'package:zimple/utils/constants.dart';

class WeekView extends StatelessWidget {
  WeekView(
      {@required int numberOfDays,
      @required double minuteHeight,
      @required this.events,
      @required this.didTapEvent,
      @required this.dates,
      this.didTapHour,
      this.didDoubleTapHour})
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
      DateTime date = dates[0];
      return isCurrentWeek(date);
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
                            dates, eventLayoutManager, dayWidth),
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

  List<Widget> _buildHoursAndEvents(List<DateTime> dates,
      EventLayoutManager eventLayoutManager, double dayWidth) {
    return List.generate(_numberOfDays, (index) {
      List<Widget> events = eventLayoutManager.buildEventContainers(index);
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: const Border(
                left: BorderSide(width: 0.2),
              ),
            ),
            child:
                Column(children: _buildHourContainer(dates[index], dayWidth)),
          ),
          if (events.isNotEmpty)
            Stack(
              children: events,
            ),
        ],
      );
    });
  }

  List<Widget> _buildHourContainer(DateTime date, double dayWidth) {
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
          color: isToday(date) ? Colors.lightBlue.shade50 : Colors.white,
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
    this.minuteHeight,
    this.dayWidth,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * minuteHeight,
      width: dayWidth - 0.2,
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(width: 0.2),
        ),
        color: color,
      ),
    );
  }
}

class CurrentTimeLine extends StatefulWidget {
  double minuteHeight;
  CurrentTimeLine({this.minuteHeight});
  @override
  _CurrentTimeLineState createState() => _CurrentTimeLineState();
}

class _CurrentTimeLineState extends State<CurrentTimeLine> {
  var now = DateTime.now();
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
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
