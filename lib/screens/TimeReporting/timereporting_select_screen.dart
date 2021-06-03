import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/components/timeplan.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import 'package:zimple/widgets/rounded_button.dart';

import 'add_timereport_screen.dart';

class TimeReportingSelectScreen extends StatefulWidget {
  static const routeName = "time_reporting_select_screen";
  final EventManager eventManager;
  TimeReportingSelectScreen({this.eventManager});

  @override
  _TimeReportingSelectScreenState createState() =>
      _TimeReportingSelectScreenState();
}

class _TimeReportingSelectScreenState extends State<TimeReportingSelectScreen> {
  EventManager _filteredEventManager(BuildContext context) {
    UserParameters user =
        Provider.of<ManagerProvider>(context, listen: false).user;
    var eventManager = widget.eventManager;
    eventManager.eventFilter = (events) {
      return events.where((event) {
        return event.persons.map((p) => p.id).contains(user.token);
      }).toList();
    };
    return eventManager;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0.0,
            toolbarHeight: 75,
            title: Text("Välj vilket event du vill tidrapportera för",
                maxLines: 2, style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Stack(
            children: [
              Timeplan(
                eventManager: _filteredEventManager(context),
                appBarEnabled: false,
                shouldShowIsTimereported: true,
                didTapEvent: (event) {
                  pushNewScreen(context,
                      screen: AddTimeReportingScreen(
                        selectedEvent: event,
                      ));
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: RectangularButton(
                      onTap: () {
                        pushNewScreen(context,
                            screen: AddTimeReportingScreen());
                      },
                      text: "Rapportera ej planerad tid"),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
