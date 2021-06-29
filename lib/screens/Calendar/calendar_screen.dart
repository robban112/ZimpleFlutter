import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/components/timeplan.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/screens/drawer.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../../components/week_page_controller_new.dart';
import '../../network/firebase_event_manager.dart';
import '../../network/firebase_user_manager.dart';
import '../../managers/event_manager.dart';
import '../../managers/person_manager.dart';
import '../../utils/date_utils.dart';
import '../../utils/days_changed_controller.dart';
import '../../widgets/rounded_button.dart';
import 'AddEvent/add_event_screen.dart';
import 'event_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = 'calendar_screen';
  final EventManager eventManager;
  final FirebaseEventManager firebaseEventManager;
  final UserParameters user;
  final PersonManager personManager;

  const CalendarScreen({
    required this.user,
    required this.personManager,
    required this.firebaseEventManager,
    required this.eventManager,
  });
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late FirebaseUserManager firebaseUserManager;
  late FirebaseStorageManager firebaseStorageManager;
  bool loading = true;
  double _minuteHeight = 0.6;
  int _numberOfDays = 7;
  late DateTime dateAggregator;
  bool isCopyingEvent = false;
  Event? eventToCopy;
  bool isShowingTimeplan = false;
  bool viewingMySchedule = false;
  late Map<Person, bool> _filteredPersons;
  WeekPageController daysChangedController = WeekPageController();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  late StreamSubscription<EventManager> eventManagerSubscriber;

  @override
  void initState() {
    super.initState();
    isShowingTimeplan = !widget.user.isAdmin;
    dateAggregator = firstDayOfWeek(DateTime.now());
    firebaseStorageManager =
        FirebaseStorageManager(company: widget.user.company);
    firebaseUserManager = FirebaseUserManager();
    _filteredPersons = new Map.fromIterable(widget.personManager.persons,
        key: (person) => person, value: (person) => true);
    //filteredPersons = widget.personManager.persons;
  }

  @override
  void dispose() {
    super.dispose();
    eventManagerSubscriber.cancel();
  }

  Widget _buildBody() {
    return ProviderWidget(
      didTapEvent: this._didTapEvent,
      drawerKey: _drawerKey,
      child: isShowingTimeplan
          ? Timeplan(
              eventManager: widget.eventManager,
              didTapEvent: _didTapEvent,
              shouldShowIsTimereported: false,
            )
          : Stack(
              children: [
                WeekPageControllerNew(
                  eventManager: widget.eventManager,
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
                  didDoubleTapHour: (date, index) {
                    print("Double dap date: $date");
                    if (this._numberOfDays == 1) {
                      setState(() {
                        this._numberOfDays = 7;
                      });
                      daysChangedController.daysChanged(1, 7, null);
                    } else {
                      daysChangedController.daysChanged(7, 1, date);
                      setState(() {
                        this._numberOfDays = 1;
                      });
                    }
                  },
                ),
                buildCopyWidget()
              ],
            ),
    );
  }

  void _didTapEvent(Event event) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return EventDetailScreen(
            key: UniqueKey(),
            event: event,
            firebaseEventManager: widget.firebaseEventManager,
            firebaseStorageManager: firebaseStorageManager,
            didTapCopyEvent: (event) {
              setState(() {
                eventToCopy = event;
                isCopyingEvent = true;
              });
            },
            didTapChangeEvent: (event) {
              pushNewScreen(context,
                  screen: AddEventScreen(
                    persons: widget.personManager.persons,
                    firebaseEventManager: widget.firebaseEventManager,
                    firebaseStorageManager: this.firebaseStorageManager,
                    eventToChange: event,
                  ));
            },
          );
        });
  }

  void copyEvent(DateTime date, int index) {
    if (eventToCopy == null) return;
    var start = DateTime(
        date.year, date.month, date.day, index, eventToCopy!.start.minute);
    var diff = eventToCopy!.end.difference(eventToCopy!.start).inHours;
    var end = DateTime(date.year, date.month, date.day, index + diff,
        eventToCopy!.start.minute);
    eventToCopy!.start = start;
    eventToCopy!.end = end;
    eventToCopy!.timereported = [];
    widget.firebaseEventManager.addEvent(eventToCopy!);
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

  void _toggleTimeplanView() {
    setState(() {
      this.isShowingTimeplan = true;
    });
    Navigator.pop(context);
  }

  void _setNumberOfDays(int numberOfDays) {
    var prevNumberOfDays = this._numberOfDays;
    setState(() {
      this.isShowingTimeplan = false;
      this._numberOfDays = numberOfDays;
      Navigator.pop(context);
    });
    daysChangedController.daysChanged(prevNumberOfDays, numberOfDays, null);
  }

  void _didSetFilterForPersons(Person person) {
    print("filter for: $person");
    setState(() {
      if (_filteredPersons[person] == null) return;
      this._filteredPersons[person] = !this._filteredPersons[person]!;
      this.widget.eventManager.eventFilter = (events) {
        return events
            .where((event) =>
                event.persons?.any((p) => this._filteredPersons[p]!) ?? false)
            .toList();
      };
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      floatingActionButton: widget.user.isAdmin
          ? FloatingActionButton(
              backgroundColor: green,
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
                        firebaseEventManager: widget.firebaseEventManager,
                        firebaseStorageManager: this.firebaseStorageManager,
                      ),
                    ));
              },
            )
          : Container(),
      drawer: DrawerWidget(
        setNumberOfDays: _setNumberOfDays,
        toggleTimeplanView: _toggleTimeplanView,
        filteredPersons: this._filteredPersons,
        didSetFilterForPersons: this._didSetFilterForPersons,
        persons: widget.personManager.persons,
      ),
      body: _buildBody(),
    );
  }
}
