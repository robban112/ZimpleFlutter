import 'package:zimple/utils/date_utils.dart';
import 'package:flutter/material.dart';
import '../model/event.dart';
import 'vertical_time_container.dart';
import 'week_header.dart';
import '../utils/event_layout_manager.dart';
import '../utils/date_utils.dart';

class WeekView extends StatelessWidget {
  WeekView(
      {@required int numberOfDays,
      @required double minuteHeight,
      @required this.events,
      @required this.didTapEvent,
      @required this.dates,
      this.didTapHour})
      : _numberOfDays = numberOfDays,
        _minuteHeight = minuteHeight;

  final int _numberOfDays;
  final double _minuteHeight;
  final List<Event> events;
  final List<DateTime> dates;
  final Function(Event) didTapEvent;
  final Function(DateTime, int) didTapHour;

  final double verticalTimeContainerWidth = 45;

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
      decoration: BoxDecoration(color: Colors.blueGrey),
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
              child: Row(
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
            )
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
      width: dayWidth - 0.3,
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(width: 0.2),
        ),
        color: color,
      ),
    );
  }
}
