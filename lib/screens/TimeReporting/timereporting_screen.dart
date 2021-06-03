import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/screens/TimeReporting/timereporting_list_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_select_screen.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/weekday_to_string.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import '../../widgets/rounded_button.dart';
import 'package:zimple/utils/date_utils.dart';

class TimeReportingScreen extends StatefulWidget {
  static const routeName = "time_reporting_screen";
  final EventManager eventManager;
  final PersonManager personManager;
  final UserParameters user;
  TimeReportingScreen({this.eventManager, this.personManager, this.user});
  @override
  _TimeReportingScreenState createState() => _TimeReportingScreenState();
}

class _TimeReportingScreenState extends State<TimeReportingScreen> {
  TimereportManager timereportManager;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildSectionTitle(String title, {IconData leadingIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          leadingIcon != null ? Icon(leadingIcon) : Container(),
          leadingIcon != null ? SizedBox(width: 5.0) : Container(),
          Text(title,
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFunctionRow(String title, IconData icon, Function onTap) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 10.0,
        title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Tidrapportering",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0))),
      ),
      body: Stack(
        children: [
          Container(
              height: size.height, width: size.width, color: backgroundColor),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLatestTimereports(context),
                  SizedBox(height: 24.0),
                  _buildSectionTitle("Funktioner"),
                  _buildFunctionRow("Rapportera tid", Icons.access_time,
                      goToTimeReportingSelect),
                  _buildFunctionRow(
                      "Rapportera sjukdom", Icons.bar_chart, () {}),
                  _buildFunctionRow(
                      "Ansök om ledighet", Icons.bar_chart, () {}),
                  _buildFunctionRow(
                      "Visa mina utgifter", Icons.bar_chart, () {}),
                  _buildSectionTitle("Admin"),
                  _buildFunctionRow(
                      "Visa alla tidrapporter", Icons.bar_chart, () {}),
                  _buildFunctionRow("Se statistik", Icons.bar_chart, () {}),
                  _buildFunctionRow(
                      "Visa alla utgifter", Icons.bar_chart, () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _buildLatestTimereports(BuildContext context) {
    var timereports = Provider.of<ManagerProvider>(context, listen: true)
        .timereportManager
        .getTimereports(widget.user.token);
    return timereports.isNotEmpty
        ? Column(
            children: [
              buildLatestTimereportTitle(),
              SizedBox(height: 12.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TimeReportList(
                  timereports: timereports.take(12).toList(),
                ),
              ),
            ],
          )
        : Container();
  }

  void goToTimeReportingSelect() {
    pushNewScreen(
      context,
      screen: TimeReportingSelectScreen(
        eventManager: widget.eventManager,
      ),
    );
  }

  Row buildLatestTimereportTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Mina senaste tidrapporter",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
        TextButton(
          child: Text("Visa alla",
              style: TextStyle(color: green, fontWeight: FontWeight.bold)),
          onPressed: () {
            pushNewScreen(context, screen: TimereportingListScreen());
          },
        )
      ],
    );
  }
}

class TimeReportList extends StatelessWidget {
  final List<TimeReport> timereports;
  TimeReportList({this.timereports});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: timereports
          .map(
            (timereport) => TimeReportCard(
              timereport: timereport,
            ),
          )
          .toList(),
    );
  }
}

class TimeReportCard extends StatefulWidget {
  final TimeReport timereport;
  TimeReportCard({this.timereport});
  @override
  _TimeReportCardState createState() => _TimeReportCardState();
}

class _TimeReportCardState extends State<TimeReportCard> {
  Color _backgroundColor = Colors.white;
  Color _highlightColor = Colors.grey.shade300;
  Color _color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          pushNewScreen(context,
              screen: TimereportingDetails(
                timereport: widget.timereport,
              ));
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 4,
                  blurRadius: 4,
                  offset: Offset(-2, 2), // changes position of shadow
                )
              ]),
          width: 175,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFirstRow(),
                SizedBox(height: 12.0),
                Text("Tink"),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Text(dateToHourMinute(widget.timereport.startDate)),
                    Text(" - "),
                    Text(dateToHourMinute(widget.timereport.endDate))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHourDiff() {
    var minutes = widget.timereport.endDate
        .difference(widget.timereport.startDate)
        .inMinutes;
    var minutesToHours = minutes / 60;
    return "${minutes / 60}";
  }

  Row buildFirstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dayNumberInMonth(widget.timereport.startDate),
                style: TextStyle(fontSize: 21.0)),
            Text(dateToAbbreviatedString(widget.timereport.startDate),
                style: TextStyle(color: Colors.grey))
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_getHourDiff(), style: TextStyle(fontSize: 21.0)),
            Text("timmar", style: TextStyle(color: Colors.grey))
          ],
        )
      ],
    );
  }
}
