import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/utils/generic_imports.dart';

class TimeReportRowItem extends StatelessWidget {
  final TimeReport timereport;

  final Function(TimeReport) onTapTimeReport;

  const TimeReportRowItem({
    Key? key,
    required this.timereport,
    required this.onTapTimeReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Event? event = EventManager.of(context).getEventForKey(key: timereport.eventId);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTapTimeReport(timereport),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ProfilePictureIcon(
                  person: PersonManager.of(context).getPersonById(timereport.userId!),
                  size: Size(30, 30),
                ),
                const SizedBox(width: 12),
                _buildTitle(context, event),
              ],
            ),
            Row(
              children: [
                _buildTrailingHours(context),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: ThemeNotifier.of(context).textColor),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingHours(BuildContext context) {
    String hours = getHourDiff(timereport.startDate, timereport.endDate, minutesBreak: timereport.breakTime);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: hours,
            style: textStyle(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: " "),
          TextSpan(
            text: "h",
            style: textStyle(context).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeNotifier.of(context).textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildTitle(BuildContext context, Event? event) {
    return Container(
      width: width(context) * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title(context, event),
            style: textStyle(context).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            children: [
              Text(
                "${monthDayString(timereport.startDate)} • ",
                style: textStyle(context).copyWith(
                  fontSize: 14,
                  color: ThemeNotifier.of(context).textColor.withOpacity(0.5),
                ),
              ),
              TimeBetweenText(
                start: timereport.startDate,
                end: timereport.endDate,
                minutesBreak: timereport.breakTime,
                opacity: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String title(BuildContext context, Event? event) {
    if (event != null) return event.title;
    Customer? customer = CustomerManager.of(context).getCustomer(timereport.customerKey);
    if (customer != null) return customer.name;

    return getDayString(timereport.startDate);
  }
}
