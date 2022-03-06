import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/screens/TimeReporting/TimereportList/timereport_row_item.dart';
import 'package:zimple/utils/theme_manager.dart';

class TimeReportListWidget extends StatelessWidget {
  final List<TimeReport> timereports;

  final Function(TimeReport) onTapTimeReport;

  const TimeReportListWidget({
    Key? key,
    required this.timereports,
    required this.onTapTimeReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        TimeReport timereport = timereports[index];
        return TimeReportRowItem(
          timereport: timereport,
          onTapTimeReport: onTapTimeReport,
        );
      },
      itemCount: timereports.length,
      separatorBuilder: (context, index) => TimeReportListSeparator(),
    );
  }
}

class TimeReportListSeparator extends StatelessWidget {
  const TimeReportListSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 40),
      color: ThemeNotifier.of(context).borderColor,
      width: double.infinity,
      height: 2,
    );
  }
}
