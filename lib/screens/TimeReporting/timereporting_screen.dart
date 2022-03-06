import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_vacation_manager.dart';
import 'package:zimple/screens/TimeReporting/AddTimereport/add_timereport_easy_screen.dart';
import 'package:zimple/screens/TimeReporting/Components/timereport_card.dart';
import 'package:zimple/screens/TimeReporting/SalaryBasis/salary_basis_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/abscence_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/report_vacation_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/select_vacation_person_screen.dart';
import 'package:zimple/screens/TimeReporting/add_timereport_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_list_screen.dart';
import 'package:zimple/widgets/widgets.dart';

import 'Components/timereport_overview.dart';

class TimeReportingScreen extends StatefulWidget {
  static const routeName = "time_reporting_screen";

  final EventManager eventManager;

  final PersonManager personManager;

  final UserParameters user;

  TimeReportingScreen({required this.eventManager, required this.personManager, required this.user});
  @override
  _TimeReportingScreenState createState() => _TimeReportingScreenState();
}

class _TimeReportingScreenState extends State<TimeReportingScreen> {
  late TimereportManager timereportManager;
  late FirebaseVacationManager firebaseVacationReportManager;

  @override
  void initState() {
    firebaseVacationReportManager = FirebaseVacationManager(company: widget.user.company);
    firebaseVacationReportManager.getUnreadAbsenceRequests().then((value) {
      print("Updated vacation absence");
      Provider.of<ManagerProvider>(context, listen: false).absenceRequestReadMap = value;
      setState(() {});
    });
    super.initState();
  }

  Widget _buildSectionTitle(String title, {IconData? leadingIcon}) {
    return ListedTitle(text: title);
  }

  @override
  Widget build(BuildContext context) {
    print("Building Timereporting Screen");
    var size = MediaQuery.of(context).size;

    return FocusDetector(
      onFocusGained: () {
        setState(() {});
      },
      child: Scaffold(
        appBar: appBar("Tidrapportering", withBackButton: false),
        body: BackgroundWidget(child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    Map<String, int>? absenceMap = Provider.of<ManagerProvider>(context, listen: true).absenceRequestReadMap;
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.0),
          TimereportOverview(),
          _buildLatestTimereports(context),
          _buildSectionTitle("Funktioner".toUpperCase()),
          _buildFunctionsListedView(),
          widget.user.isAdmin
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildSectionTitle("Admin".toUpperCase()),
                )
              : Container(),
          widget.user.isAdmin ? _buildAdminFunctionsListedView(absenceMap) : Container(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  ListedView _buildFunctionsListedView() {
    return ListedView(
      rowInset: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      items: [
        ListedItem(
            leadingIcon: Icons.access_time,
            text: "Tidrapportera",
            trailingIcon: Icons.chevron_right,
            onTap: goToNewAddTimereportingScreen),
        ListedItem(
            leadingIcon: Icons.access_time,
            text: "Rapportera fristående tid",
            trailingIcon: Icons.chevron_right,
            onTap: goToAddTimereportScreen),
        ListedItem(
            leadingIcon: Icons.money,
            text: "Löneunderlag",
            trailingIcon: Icons.chevron_right,
            onTap: () => pushNewScreen(context, screen: SalaryBasisScreen())),
        ListedItem(
            leadingIcon: Icons.wb_sunny,
            text: "Ansök frånvaro",
            trailingIcon: Icons.chevron_right,
            onTap: () => pushNewScreen(context, screen: ReportVacationScreen())),
        ListedItem(
            leadingIcon: Icons.alarm_off,
            text: "Min frånvaro",
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
        Text(
          "Frånvaroansökningar",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberOfUnreadAbsenceRequests(Map<String, int>? absenceMap) {
    if (absenceMap == null) return Container();
    int totalUnread = FirebaseVacationManager.getTotalUnreadAbsenceRequests(absenceMap);
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
            text: "Alla tidrapporter",
            trailingIcon: Icons.chevron_right,
            onTap: goToShowAllTimereportScreen),
        //ListedItem(leadingIcon: Icons.bar_chart, child: Text("Se statistik"), trailingIcon: Icons.chevron_right),
        ListedItem(
            leadingIcon: Icons.alarm_off,
            child: _buildAbsenceChild(),
            trailingWidget: Row(
              children: [_buildNumberOfUnreadAbsenceRequests(absenceMap), Icon(Icons.chevron_right)],
            ),
            onTap: () => pushNewScreen(context, screen: SelectVacationPersonScreen(unreadAbsenceMap: absenceMap))),
      ],
    );
  }

  Widget _buildLatestTimereports(BuildContext context) {
    List<TimeReport> timereports = getLatestTimereports();
    return timereports.isNotEmpty
        ? Column(
            children: [
              buildLatestTimereportTitle(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: TimeReportList(
                  timereports: timereports.take(12).toList(),
                  eventManager: widget.eventManager,
                ),
              ),
              SizedBox(height: 24.0),
            ],
          )
        : Container();
  }

  List<TimeReport> getLatestTimereports() {
    if (widget.user.isAdmin) {
      return TimereportManager.of(context).getLatestTimereports();
    }
    return TimereportManager.of(context).getTimereports(widget.user.token);
  }

  void goToShowAllTimereportScreen() {
    pushNewScreen(context, screen: TimereportingListScreen());
  }

  void goToAddTimereportScreen() {
    pushNewScreen(context, screen: AddTimeReportingScreen(eventManager: widget.eventManager));
  }

  void goToNewAddTimereportingScreen() {
    pushNewScreen(context, screen: AddTimereportEasyScreen());
  }

  Widget buildLatestTimereportTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Senaste rapporter", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0)),
          TextButton(
            child: Text("Visa alla", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            onPressed: () {
              if (widget.user.isAdmin) {
                goToShowAllTimereportScreen();
              } else {
                pushNewScreen(context,
                    screen: TimereportingListScreen(
                      userId: widget.user.token,
                    ));
              }
            },
          )
        ],
      ),
    );
  }
}
