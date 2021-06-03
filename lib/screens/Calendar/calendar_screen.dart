import 'dart:async';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/components/timeplan.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../../components/week_page_controller_new.dart';
import '../../network/firebase_event_manager.dart';
import '../../network/firebase_user_manager.dart';
import '../../network/firebase_person_manager.dart';
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
    @required this.user,
    @required this.personManager,
    @required this.firebaseEventManager,
    @required this.eventManager,
  });
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String userName;
  String userToken;
  UserParameters user;
  FirebaseUserManager firebaseUserManager;
  FirebaseStorageManager firebaseStorageManager;
  bool loading = true;
  double _minuteHeight = 0.6;
  int _numberOfDays = 7;
  DateTime dateAggregator;
  bool isCopyingEvent = false;
  Event eventToCopy;
  bool isShowingTimeplan = false;
  bool viewingMySchedule = false;
  Map<Person, bool> _filteredPersons;
  WeekPageController daysChangedController = WeekPageController();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  StreamSubscription<EventManager> eventManagerSubscriber;

  @override
  void initState() {
    super.initState();
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

  Future<String> getCurrentUserToken() {
    return FirebaseAuth.instance.currentUser.getIdToken();
  }

  Widget _buildBody() {
    return ProviderWidget(
      didTapEvent: this._didTapEvent,
      drawerKey: _drawerKey,
      child: isShowingTimeplan
          ? Timeplan(
              eventManager: widget.eventManager,
              didTapEvent: _didTapEvent,
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
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
    eventToCopy.timereported = [];
    widget.firebaseEventManager.addEvent(eventToCopy);
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
      this._filteredPersons[person] = !this._filteredPersons[person];
      this.widget.eventManager.eventFilter = (events) {
        return events
            .where(
                (event) => event.persons.any((p) => this._filteredPersons[p]))
            .toList();
      };
    });
  }

  void _toggleFilterForAll(bool toggle) {
    print("Tja");
  }

  // filteredPersons = personIds;
  // if (personIds.isNotEmpty) {
  //   this.widget.eventManager.eventFilter = (events) {
  //     return events.where((event) {
  //       var containsAny = false;
  //       var personsIds = event.persons.map((p) => p.id);
  //       personsIds.forEach((id) {
  //         if (personsIds.contains(id)) {
  //           containsAny = true;
  //         }
  //       });
  //       return containsAny;
  //     }).toList();
  //   };
  // } else {
  //   this.widget.eventManager.eventFilter = null;
  // }
  //}

  void test() {}

  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      floatingActionButton: FloatingActionButton(
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
      ),
      drawer: DrawerWidget(
        setNumberOfDays: _setNumberOfDays,
        toggleTimeplanView: _toggleTimeplanView,
        filteredPersons: this._filteredPersons,
        didSetFilterForPersons: this._didSetFilterForPersons,
        toggleFilterForAll: this._toggleFilterForAll,
        persons: widget.personManager.persons,
      ),
      body: _buildBody(),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  final Function(int) setNumberOfDays;
  final Function toggleTimeplanView;
  final Map<Person, bool> filteredPersons;
  final void Function(Person) didSetFilterForPersons;
  final void Function(bool) toggleFilterForAll;
  final List<Person> persons;
  DrawerWidget(
      {@required this.setNumberOfDays,
      @required this.toggleTimeplanView,
      @required this.filteredPersons,
      @required this.didSetFilterForPersons,
      @required this.toggleFilterForAll,
      @required this.persons});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isFilteringPersonsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Container(
                  height: 30.0,
                  child: Image.asset('images/zimple_logo_black.png'),
                ),
              ),
            ),
            ListTile(
              title: Text("Tidsplan"),
              leading: Icon(Icons.view_agenda),
              onTap: () {
                this.widget.toggleTimeplanView();
              },
            ),
            ListTile(
              title: Text("Dag"),
              leading: Icon(Icons.view_day),
              onTap: () {
                this.widget.setNumberOfDays(1);
              },
            ),
            ListTile(
              title: Text("3 dagar"),
              leading: Icon(Icons.view_column),
              onTap: () {
                this.widget.setNumberOfDays(3);
              },
            ),
            ListTile(
              title: Text("Vecka"),
              leading: Icon(Icons.view_column),
              onTap: () {
                this.widget.setNumberOfDays(7);
              },
            ),
            SizedBox(height: 30),
            //buildViewMySchedule(),
            _buildFilterPersonsItem()
          ],
        ),
      ),
    );
  }

  Padding _buildFilterPersonsItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ExpansionPanelList(
        dividerColor: Colors.transparent,
        expansionCallback: (temp, _) {
          this.setState(() => this.isFilteringPersonsExpanded =
              !this.isFilteringPersonsExpanded);
        },
        elevation: 0,
        children: [
          ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: this.isFilteringPersonsExpanded,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                    color: Colors.transparent,
                    height: 50,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Filtrera personer")));
              },
              body: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.persons.length,
                    itemBuilder: (context, index) {
                      var person = widget.persons[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                PersonCircleAvatar(person: person),
                                SizedBox(width: 12.0),
                                SizedBox(
                                  width: 100,
                                  child: ClipRRect(
                                    child: Text(
                                      person.name,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Checkbox(
                                value: widget.filteredPersons[person],
                                onChanged: (val) {
                                  widget.didSetFilterForPersons(person);
                                })
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, _) => SizedBox(height: 0.0),
                  ),
                  SizedBox(height: 75)
                ],
              )),
        ],
      ),
    );
  }
}
