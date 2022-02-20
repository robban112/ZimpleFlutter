import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/weekday_to_string.dart';
import 'package:zimple/widgets/widgets.dart';

class TimeReportList extends StatelessWidget {
  final List<TimeReport> timereports;
  final EventManager eventManager;
  TimeReportList({required this.timereports, required this.eventManager});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: timereports
          .map(
            (timereport) =>
                TimeReportCard(timereport: timereport, event: eventManager.getEventForKey(key: timereport.eventId ?? "")),
          )
          .toList(),
    );
  }
}

class TimeReportCard extends StatefulWidget {
  final TimeReport timereport;
  final Event? event;
  TimeReportCard({required this.timereport, this.event});
  @override
  _TimeReportCardState createState() => _TimeReportCardState();
}

class _TimeReportCardState extends State<TimeReportCard> {
  static final highlightColor = Colors.white.withOpacity(0.05);
  static final softHighlightColor = highlightColor.withOpacity(0.03);
  static final shadowColor = Colors.black87;
  static final softShadowColor = shadowColor.withOpacity(0.15);
  @override
  Widget build(BuildContext context) {
    var spacing = 8.0;
    var eventAvailable = widget.event != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
          boxShadow: [
            BoxShadow(color: softHighlightColor, offset: Offset(-3, -3), spreadRadius: 0, blurRadius: 3),
            BoxShadow(color: softShadowColor, offset: Offset(3, 3), spreadRadius: 0.5, blurRadius: 8),
          ],
        ),
        width: 220,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            splashColor: Colors.grey.shade300,
            onTap: () {
              pushNewScreen(context,
                  screen: TimereportingDetails(
                    timereport: widget.timereport,
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12, top: 7, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFirstRow(),
                  SizedBox(height: spacing),
                  Text(widget.event?.customer ?? "", style: TextStyle(fontSize: 14)),
                  SizedBox(height: spacing),
                  const SizedBox(height: 10),
                  TimeBetweenText(
                    start: widget.timereport.startDate,
                    end: widget.timereport.endDate,
                    withHours: true,
                    minutesBreak: widget.timereport.breakTime,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row buildFirstRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: ProfilePictureIcon(person: PersonManager.of(context).getPersonById(widget.timereport.userId ?? "")),
            ),
            const SizedBox(width: 6),
            Container(width: 130, child: _buildTitle(context)),
          ],
        ),
        const SizedBox(width: 8),
        Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayNumberInMonth(widget.timereport.startDate),
                style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                dateToAbbreviatedString(widget.timereport.startDate),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.event == null) return _title("");
    if (widget.event?.customerKey == null) return _title(widget.event!.title);
    Customer? customer = ManagerProvider.of(context).customerManager.getCustomer(widget.event!.customerKey!);
    if (customer == null) return _title(widget.event!.title);
    return _title(widget.event!.title);
  }

  Text _title(String text) =>
      Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}
