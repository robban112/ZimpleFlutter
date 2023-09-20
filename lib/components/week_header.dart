import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:zimple/utils/constants.dart';

import '../utils/date_utils.dart';
import '../utils/weekday_to_string.dart';

class WeekHeader extends StatelessWidget {
  final int _numberOfDays;
  final List<DateTime> _dates;
  final double _leftPadding;
  final double _dayWidth;
  WeekHeader({
    required int numberOfDays,
    required List<DateTime> dates,
    required double leftPadding,
    required double dayWidth,
  })  : _numberOfDays = numberOfDays,
        _dates = dates,
        _leftPadding = leftPadding,
        _dayWidth = dayWidth;

  final double padding = 7.0;
  @override
  Widget build(BuildContext context) {
    DateFormat formattedDate = DateFormat(DateFormat.DAY, locale);
    bool shouldSkipWeekends = CalendarSettings.of(context).shouldSkipWeekends;
    return Container(
      margin: EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.1), spreadRadius: 1),
        ],
      ),
      child: _buildDateHeaders(shouldSkipWeekends, context, formattedDate),
    );
  }

  Padding _buildDateHeaders(bool shouldSkipWeekends, BuildContext context, DateFormat formattedDate) {
    return Padding(
      padding: EdgeInsets.only(left: _leftPadding),
      child: Row(
        children: List.generate(_numberOfDays, (index) {
          if (shouldSkipWeekends && (index == 5 || index == 6)) return Container();
          return Container(
            width: _dayWidth,
            child: Padding(
              padding: EdgeInsets.only(top: padding, bottom: padding),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor:
                        isToday(_dates[index]) ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.background,
                    child: Text(formattedDate.format(_dates[index]),
                        style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: isToday(_dates[index]) ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
                  ),
                  SizedBox(height: 2.0),
                  Text(dateToAbbreviatedString(_dates[index]).toUpperCase(), style: TextStyle(fontSize: 11.0, color: null)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
