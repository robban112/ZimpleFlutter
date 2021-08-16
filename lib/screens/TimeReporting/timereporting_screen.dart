import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:zimple/network/firebase_vacation_manager.dart';
import 'package:zimple/screens/TimeReporting/Vacation/abscence_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/report_vacation_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/select_vacation_person_screen.dart';
import 'package:zimple/screens/TimeReporting/add_timereport_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/screens/TimeReporting/timereporting_list_screen.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/weekday_to_string.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/listed_view.dart';
import 'package:zimple/utils/date_utils.dart';

class TimeReportingScreen extends StatefulWidget {
  static const routeName = "time_reporting_screen";
  final EventManager eventManager;
  final PersonManager personManager;
  final UserParameters user;
  TimeReportingScreen(
      {required this.eventManager,
      required this.personManager,
      required this.user});
  @override
  _TimeReportingScreenState createState() => _TimeReportingScreenState();
}

class _TimeReportingScreenState extends State<TimeReportingScreen> {
  late TimereportManager timereportManager;
  late FirebaseVacationManager firebaseVacationReportManager;

  @override
  void initState() {
    firebaseVacationReportManager =
        FirebaseVacationManager(company: widget.user.company);
    firebaseVacationReportManager.getUnreadAbsenceRequests().then((value) {
      print("Updated vacation absence");
      Provider.of<ManagerProvider>(context, listen: false)
          .absenceRequestReadMap = value;
      setState(() {});
    });
    super.initState();
  }

  Widget _buildSectionTitle(String title, {IconData? leadingIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          leadingIcon != null ? Icon(leadingIcon) : Container(),
          leadingIcon != null ? SizedBox(width: 5.0) : Container(),
          Text(title,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building Timereporting Screen");
    var size = MediaQuery.of(context).size;
    Map<String, int>? absenceMap =
        Provider.of<ManagerProvider>(context, listen: true)
            .absenceRequestReadMap;
    return FocusDetector(
      onFocusGained: () {
        setState(() {});
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 10.0,
          brightness: Brightness.dark,
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
            Container(height: size.height, width: size.width),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.0),
                  _buildLatestTimereports(context),
                  SizedBox(height: 24.0),
                  _buildSectionTitle("Funktioner"),
                  _buildFunctionsListedView(),
                  widget.user.isAdmin
                      ? _buildSectionTitle("Admin")
                      : Container(),
                  widget.user.isAdmin
                      ? _buildAdminFunctionsListedView(absenceMap)
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListedView _buildFunctionsListedView() {
    return ListedView(
      rowInset: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      items: [
        ListedItem(
            leadingIcon: Icons.access_time,
            child: Text(
              "Rapportera tid",
            ),
            trailingIcon: Icons.chevron_right,
            onTap: goToAddTimereportScreen),
        ListedItem(
            leadingIcon: Icons.wb_sunny,
            child: Text("Ansök frånvaro"),
            trailingIcon: Icons.chevron_right,
            onTap: () =>
                pushNewScreen(context, screen: ReportVacationScreen())),
        ListedItem(
            leadingIcon: Icons.alarm_off,
            child: Text("Min frånvaro"),
            trailingIcon: Icons.chevron_right,
            onTap: () => pushNewScreen(context,
                screen: AbsenceScreen(
                  userId: widget.user.token,
                  company: widget.user.company,
                ))),
      ],
    );
  }

  Widget _buildAbsenceChild() {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Text("Visa frånvaroansökningar"),
      ],
    );
  }

  Widget _buildNumberOfUnreadAbsenceRequests(Map<String, int>? absenceMap) {
    if (absenceMap == null) return Container();
    int totalUnread =
        FirebaseVacationManager.getTotalUnreadAbsenceRequests(absenceMap);
    if (totalUnread <= 0) return Container();
    return CircleAvatar(
      radius: 10,
      backgroundColor: Colors.red,
      child: Text(
        "$totalUnread",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  ListedView _buildAdminFunctionsListedView(Map<String, int>? absenceMap) {
    return ListedView(
      rowInset: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      items: [
        ListedItem(
            leadingIcon: Icons.all_inbox,
            child: Text(
              "Visa alla tidrapporter",
            ),
            trailingIcon: Icons.chevron_right,
            onTap: goToShowAllTimereportScreen),
        ListedItem(
            leadingIcon: Icons.bar_chart,
            child: Text("Se statistik"),
            trailingIcon: Icons.chevron_right),
        ListedItem(
            leadingIcon: Icons.alarm_off,
            child: _buildAbsenceChild(),
            trailingWidget: Row(
              children: [
                _buildNumberOfUnreadAbsenceRequests(absenceMap),
                Icon(Icons.chevron_right)
              ],
            ),
            onTap: () => pushNewScreen(context,
                screen:
                    SelectVacationPersonScreen(unreadAbsenceMap: absenceMap))),
      ],
    );
  }

  Widget _buildLatestTimereports(BuildContext context) {
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
                    eventManager: widget.eventManager),
              ),
            ],
          )
        : Container();
  }

  void goToShowAllTimereportScreen() {
    pushNewScreen(context, screen: TimereportingListScreen());
  }

  void goToAddTimereportScreen() {
    pushNewScreen(context,
        screen: AddTimeReportingScreen(eventManager: widget.eventManager));
  }

  Widget buildLatestTimereportTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Mina senaste tidrapporter",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
          TextButton(
            child: Text("Visa alla",
                style: TextStyle(
                    color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            onPressed: () {
              pushNewScreen(context,
                  screen: TimereportingListScreen(
                    userId: widget.user.token,
                  ));
            },
          )
        ],
      ),
    );
  }
}

class TimeReportList extends StatelessWidget {
  final List<TimeReport> timereports;
  final EventManager eventManager;
  TimeReportList({required this.timereports, required this.eventManager});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: timereports
          .map(
            (timereport) => TimeReportCard(
                timereport: timereport,
                event:
                    eventManager.getEventForKey(key: timereport.eventId ?? "")),
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
  static final softShadowColor = shadowColor.withOpacity(0.3);
  @override
  Widget build(BuildContext context) {
    var spacing = 8.0;
    var eventAvailable = widget.event != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            boxShadow: [
              BoxShadow(
                  color: softHighlightColor,
                  offset: Offset(-3, -3),
                  spreadRadius: 0,
                  blurRadius: 3),
              BoxShadow(
                  color: softShadowColor,
                  offset: Offset(5, 5),
                  spreadRadius: 2,
                  blurRadius: 7)
            ]),
        width: 175,
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildFirstRow(),
                  SizedBox(height: spacing),
                  Text(widget.event?.customer ?? ""),
                  SizedBox(height: spacing),
                  widget.event != null
                      ? ListPersonCircleAvatar(
                          persons: widget.event?.persons ?? [],
                          radius: 10,
                          fontSize: 9)
                      : SizedBox(height: 20),
                  SizedBox(height: spacing),
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
      ),
    );
  }

  String _getHourDiff() {
    var minutes = widget.timereport.endDate
        .difference(widget.timereport.startDate)
        .inMinutes;
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
