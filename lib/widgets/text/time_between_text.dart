import 'package:flutter/material.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';

class TimeBetweenText extends StatelessWidget {
  final DateTime start;

  final DateTime end;

  final int minutesBreak;

  final bool withHours;

  final double opacity;

  const TimeBetweenText({
    Key? key,
    required this.start,
    required this.end,
    this.minutesBreak = 0,
    this.withHours = false,
    this.opacity = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          if (withHours)
            TextSpan(
                text: getHourDiff(start, end, minutesBreak: minutesBreak) + " tim",
                style: style(context, isBold: true, fontSize: 16)),
          if (withHours) TextSpan(text: " | ", style: style(context)),
          TextSpan(text: dateToHourMinute(start), style: style(context)),
          TextSpan(text: " - ", style: style(context)),
          TextSpan(text: dateToHourMinute(end), style: style(context)),
        ],
      ),
    );
  }

  TextStyle style(BuildContext context, {bool isBold = false, double fontSize = 14}) => TextStyle(
      color: ThemeNotifier.of(context).textColor.withOpacity(opacity),
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
      fontFamily: 'FiraSans');
}
