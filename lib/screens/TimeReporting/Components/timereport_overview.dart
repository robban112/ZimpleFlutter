import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:zimple/extensions/double_extensions.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/timereport_collection.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';

class TimereportOverview extends StatefulWidget {
  const TimereportOverview({Key? key}) : super(key: key);

  @override
  State<TimereportOverview> createState() => _TimereportOverviewState();
}

class _TimereportOverviewState extends State<TimereportOverview> {
  late List<String>? userIds = isAdmin(context) ? null : [user(context).token];
  int thisYear = DateTime.now().year;
  int thisMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    List<TimeReport> timereports = TimereportManager.watch(context).getTimereportForMonth(
      year: thisYear,
      month: thisMonth,
      userIds: userIds,
    );
    TimeReportCollection timereportCollection = TimeReportCollection(timereports: timereports);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 16),
          Row(
            children: [
              TimereportOverviewCard(
                title: "Antal tidrapporter",
                amount: timereports.length.toDouble(),
                appendAmountText: "tidrapporter",
                year: thisYear,
                month: thisMonth,
              ),
              const SizedBox(width: 10),
              TimereportOverviewCard(
                title: "Antal timmar",
                amount: timereportCollection.totalHoursWithoutBreak(),
                year: thisYear,
                month: thisMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Row _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Översikt", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
        //Text("Se mer »", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))
      ],
    );
  }
}

class TimereportOverviewCard extends StatelessWidget {
  final String title;

  final double amount;

  final int year;

  final int month;

  final String appendAmountText;

  const TimereportOverviewCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.year,
    required this.month,
    this.appendAmountText = "timmar",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        width: width(context) / 2 - 15,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeNotifier.of(context).textColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            const SizedBox(height: 22),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: amount.parseToTwoDigits(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: ThemeNotifier.of(context).textColor,
                    ),
                  ),
                  TextSpan(text: " "),
                  TextSpan(
                    text: appendAmountText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ThemeNotifier.of(context).textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        _buildChip(context),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${year.toString()} - ${getMonthName(month)}",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: ThemeNotifier.of(context).textColor.withOpacity(0.5),
              ),
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        )
      ],
    );
  }

  Container _buildChip(BuildContext context) => Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeNotifier.of(context).textColor.withOpacity(0.05),
        ),
        child: Icon(FeatherIcons.clock, size: 16),
      );
}
