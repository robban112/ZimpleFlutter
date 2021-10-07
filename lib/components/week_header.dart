import 'package:zimple/utils/constants.dart';
import 'package:flutter/material.dart';
import '../utils/weekday_to_string.dart';
import '../utils/date_utils.dart';
import 'package:intl/intl.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: _leftPadding),
        child: Row(
          children: List.generate(_numberOfDays, (index) {
            return Container(
              width: _dayWidth,
              child: Padding(
                padding: EdgeInsets.only(top: padding, bottom: padding),
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor:
                          isToday(_dates[index]) ? Theme.of(context).colorScheme.secondary : Theme.of(context).backgroundColor,
                      child: Text(formattedDate.format(_dates[index]),
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: isToday(_dates[index]) ? Colors.white : Theme.of(context).textTheme.bodyText1?.color)),
                    ),
                    SizedBox(height: 2.0),
                    Text(dateToAbbreviatedString(_dates[index]).toUpperCase(), style: TextStyle(fontSize: 11.0, color: null)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
