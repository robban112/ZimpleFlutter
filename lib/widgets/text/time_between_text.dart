import 'package:flutter/material.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';

class TimeBetweenText extends StatelessWidget {
  final DateTime start;

  final DateTime end;

  final int minutesBreak;

  final bool withHours;

  const TimeBetweenText({
    Key? key,
    required this.start,
    required this.end,
    this.minutesBreak = 0,
    this.withHours = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          if (withHours)
            TextSpan(text: getHourDiff(start, end, minutesBreak: minutesBreak) + " tim", style: style(context, isBold: true)),
          if (withHours) TextSpan(text: " | ", style: style(context)),
          TextSpan(text: dateToHourMinute(start), style: style(context)),
          TextSpan(text: " - ", style: style(context)),
          TextSpan(text: dateToHourMinute(end), style: style(context)),
        ],
      ),
    );
  }

  TextStyle style(BuildContext context, {bool isBold = false}) => TextStyle(
      color: ThemeNotifier.of(context).textColor,
      fontSize: 14,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
      fontFamily: 'FiraSans');
}
