import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/components/timeplan.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/button/nav_bar_back.dart';
import 'package:zimple/widgets/provider_widget.dart';

class TimeReportingSelectScreen extends StatefulWidget {
  static const routeName = "time_reporting_select_screen";
  final EventManager eventManager;
  final Function(Event) didSelectEvent;
  TimeReportingSelectScreen({required this.eventManager, required this.didSelectEvent});

  @override
  _TimeReportingSelectScreenState createState() => _TimeReportingSelectScreenState();
}

class _TimeReportingSelectScreenState extends State<TimeReportingSelectScreen> {
  // EventManager _filteredEventManager(BuildContext context) {
  //   UserParameters user =
  //       Provider.of<ManagerProvider>(context, listen: false).user;
  //   var eventManager = widget.eventManager;
  //   eventManager.eventFilter = (events) {
  //     return events.where((event) {
  //       return event.persons.map((p) => p.id).contains(user.token);
  //     }).toList();
  //   };
  //   return eventManager;
  // }

  @override
  Widget build(BuildContext context) {
    UserParameters user = Provider.of<ManagerProvider>(context, listen: true).user;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: primaryColor,
            elevation: 0.0,
            toolbarHeight: 75,
            title: Text("Välj vilken arbetsorder du vill tidrapportera för", maxLines: 2, style: TextStyle(color: Colors.white)),
            leading: NavBarBack(),
          ),
          body: Stack(
            children: [
              Timeplan(
                eventManager: widget.eventManager,
                appBarEnabled: false,
                shouldShowIsTimereported: true,
                userIdToOnlyShow: user.token,
                didTapEvent: (event) {
                  Navigator.of(context).pop();
                  widget.didSelectEvent(event);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
