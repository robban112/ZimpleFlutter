import 'dart:async';

import 'package:zimple/components/timeplan.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../../components/week_page_controller_new.dart';
import '../../network/firebase_event_manager.dart';
import '../../network/firebase_user_manager.dart';
import '../../network/firebase_person_manager.dart';
import '../../utils/event_manager.dart';
import '../../utils/person_manager.dart';
import '../../utils/date_utils.dart';
import '../../utils/days_changed_controller.dart';
import '../../widgets/rounded_button.dart';
import 'add_event_screen.dart';
import 'event_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = 'calendar_screen';
  @override
  final UserParameters user;
  final PersonManager personManager;

  const CalendarScreen({@required this.user, @required this.personManager});
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String userName;
  String userToken;
  UserParameters user;
  FirebaseEventManager firebaseEventManager;
  FirebaseUserManager firebaseUserManager;
  FirebasePersonManager firebasePersonManager;
  FirebaseStorageManager firebaseStorageManager;
  EventManager eventManager = EventManager(events: []);
  bool loading = true;
  double _minuteHeight = 0.5;
  int _numberOfDays = 7;
  DateTime dateAggregator;
  bool isCopyingEvent = false;
  Event eventToCopy;
  bool isShowingTimeplan = false;
  DaysChangedController daysChangedController;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  StreamSubscription<EventManager> eventManagerSubscriber;

  @override
  void initState() {
    super.initState();
    dateAggregator = firstDayOfWeek(DateTime.now());
    firebaseStorageManager =
        FirebaseStorageManager(company: widget.user.company);
    firebaseUserManager = FirebaseUserManager();
    daysChangedController = DaysChangedController();
    firebaseEventManager = FirebaseEventManager(
        company: widget.user.company, personManager: widget.personManager);
    eventManagerSubscriber =
        firebaseEventManager.listenEvents().listen((eventManager) {
      if (!mounted) return;
      setState(() {
        this.eventManager = eventManager;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventManagerSubscriber.cancel();
  }

  Future<String> getCurrentUserToken() {
    return FirebaseAuth.instance.currentUser.getIdToken();
  }

  Widget _buildBody() {
    return ProviderWidget(
      didTapEvent: this._didTapEvent,
      drawerKey: _drawerKey,
      child: isShowingTimeplan
          ? Timeplan(
              eventManager: this.eventManager,
              didTapEvent: _didTapEvent,
            )
          : Stack(
              children: [
                WeekPageControllerNew(
                  eventManager: this.eventManager,
                  minuteHeight: this._minuteHeight,
                  numberOfDays: this._numberOfDays,
                  daysChangedController: daysChangedController,
                  didTapEvent: this._didTapEvent,
                  didTapHour: (date, index) {
                    if (isCopyingEvent) {
                      print("upload new event at $date $index");
                      copyEvent(date, index);
                    }
                  },
                ),
                buildCopyWidget(),
              ],
            ),
    );
  }

  void _didTapEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          key: UniqueKey(),
          event: event,
          firebaseEventManager: firebaseEventManager,
          firebaseStorageManager: firebaseStorageManager,
          didTapCopyEvent: (event) {
            setState(() {
              eventToCopy = event;
              isCopyingEvent = true;
            });
          },
          didTapChangeEvent: (event) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventScreen(
                    persons: widget.personManager.persons,
                    firebaseEventManager: this.firebaseEventManager,
                    eventToChange: event,
                  ),
                ));
          },
        ),
      ),
    );
  }

  void copyEvent(DateTime date, int index) {
    var start = DateTime(
        date.year, date.month, date.day, index, eventToCopy.start.minute);
    var diff = eventToCopy.end.difference(eventToCopy.start).inHours;
    var end = DateTime(date.year, date.month, date.day, index + diff,
        eventToCopy.start.minute);
    eventToCopy.start = start;
    eventToCopy.end = end;
    firebaseEventManager.addEvent(eventToCopy);
  }

  Widget buildCopyWidget() {
    return isCopyingEvent
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  width: 250,
                  child: RoundedButton(
                    text: "Avbryt",
                    color: Colors.red,
                    onTap: () {
                      setState(() {
                        isCopyingEvent = false;
                      });
                    },
                  )),
            ),
          )
        : Container();
  }

  void _toggle_timeplan_view() {
    setState(() {
      this.isShowingTimeplan = true;
    });
    Navigator.pop(context);
  }

  void _set_number_of_days(int numberOfDays) {
    daysChangedController.daysChanged(this._numberOfDays, numberOfDays);
    setState(() {
      this.isShowingTimeplan = false;
      this._numberOfDays = numberOfDays;
      Navigator.pop(context);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEventScreen(
                  persons: widget.personManager.persons,
                  firebaseEventManager: this.firebaseEventManager,
                ),
              ));
        },
      ),
      drawer: DrawerWidget(
        setNumberOfDays: _set_number_of_days,
        toggleTimeplanView: _toggle_timeplan_view,
      ),
      body: _buildBody(),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  final Function(int) setNumberOfDays;
  final Function toggleTimeplanView;
  DrawerWidget(
      {@required this.setNumberOfDays, @required this.toggleTimeplanView});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Center(
              child: Text('Inställningar'),
            ),
          ),
          ListTile(
            title: Text("Tidsplan"),
            leading: Icon(Icons.view_agenda),
            onTap: () {
              this.toggleTimeplanView();
            },
          ),
          ListTile(
            title: Text("Dag"),
            leading: Icon(Icons.view_day),
            onTap: () {
              this.setNumberOfDays(1);
            },
          ),
          ListTile(
            title: Text("3 dagar"),
            leading: Icon(Icons.view_column),
            onTap: () {
              this.setNumberOfDays(3);
            },
          ),
          ListTile(
            title: Text("Vecka"),
            leading: Icon(Icons.view_column),
            onTap: () {
              this.setNumberOfDays(7);
            },
          ),
        ],
      ),
    );
  }
}

// class AppBarWidget extends StatefulWidget {
//   Function(Event) didChangePage;
//   Stream<DateTime> dateStream;
//   @override
//   _AppBarWidgetState createState() => _AppBarWidgetState();
// }

// class _AppBarWidgetState extends State<AppBarWidget> {
//   String appBarTitle = "";

//   //_AppBarState({})
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text("",
//           style: TextStyle(
//               color: Colors.white,
//               fontSize: 25.0,
//               fontWeight: FontWeight.bold)),
//       backgroundColor: Colors.blueGrey,
//       toolbarHeight: 75.0,
//       iconTheme: IconThemeData(color: Colors.white),
//       elevation: 0.0,
//     );
//   }
// }
