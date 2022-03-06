import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';
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
  static final shadowColor = Colors.black87.withOpacity(0.01);
  static final softShadowColor = shadowColor.withOpacity(0.15);
  @override
  Widget build(BuildContext context) {
    var spacing = 8.0;
    var eventAvailable = widget.event != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        margin: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(18.0)),
            // boxShadow: [
            //   BoxShadow(color: softHighlightColor, offset: Offset(-1, -1), spreadRadius: 0, blurRadius: 5),
            //   BoxShadow(color: softShadowColor, offset: Offset(2, 2), spreadRadius: 0.1, blurRadius: 5),
            // ],
            border: Border.all(color: ThemeNotifier.of(context).textColor.withOpacity(0.1))),
        width: 222,
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
                  Row(
                    children: [
                      _buildWorkCategoryBadge(),
                      if (isWorkCategoryAvailable) const SizedBox(width: 8),
                      Container(
                          width: 168,
                          child: Text(widget.event?.location ?? widget.event?.customer ?? "", style: TextStyle(fontSize: 14))),
                    ],
                  ),
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

  bool get isWorkCategoryAvailable => widget.event?.workCategoryId != null;

  Widget _buildWorkCategoryBadge() {
    if (!isWorkCategoryAvailable) return Container();
    WorkCategory category = WorkCategory(widget.event!.workCategoryId!);
    return buildWorkCategoryBadge(category, size: 20);
  }

  Row buildFirstRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: ProfilePictureIcon(
                  size: Size(30, 30),
                  fontSize: 14,
                  person: PersonManager.of(context).getPersonById(widget.timereport.userId ?? "")),
            ),
            const SizedBox(width: 6),
            Container(width: 120, child: _buildTitle(context)),
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
