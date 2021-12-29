import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/components/timeplan.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:flutter/material.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/screens/drawer.dart';
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

class CalendarSettings extends ChangeNotifier {
  double minuteHeight = 0.6;

  bool shouldSkipWeekends = false;

  int numberOfDays = 7;

  void setNumberOfDays(int numberOfDays) {
    this.numberOfDays = numberOfDays;
    notifyListeners();
  }

  void setShouldSkipWeekend(bool skip) {
    this.shouldSkipWeekends = skip;
    notifyListeners();
  }

  static CalendarSettings of(BuildContext context) => context.read<CalendarSettings>();

  static CalendarSettings watch(BuildContext context) => context.watch<CalendarSettings>();
}

class CalendarScreen extends StatefulWidget {
  static const String routeName = 'calendar_screen';

  final FirebaseEventManager firebaseEventManager;

  final UserParameters user;

  final PersonManager personManager;

  const CalendarScreen({
    required this.user,
    required this.personManager,
    required this.firebaseEventManager,
  });
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late FirebaseUserManager firebaseUserManager;

  late FirebaseStorageManager firebaseStorageManager;

  bool loading = true;

  late DateTime dateAggregator;

  bool isCopyingEvent = false;

  Event? eventToCopy;

  Event? eventToMove;

  Event? originalEventToMove;

  bool isShowingTimeplan = false;

  bool viewingMySchedule = false;

  bool isMovingEvent = false;

  late Map<Person, bool> _filteredPersons;

  WeekPageController daysChangedController = WeekPageController();

  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    isShowingTimeplan = !widget.user.isAdmin;
    dateAggregator = firstDayOfWeek(DateTime.now());
    firebaseStorageManager = FirebaseStorageManager(company: widget.user.company);
    firebaseUserManager = FirebaseUserManager();
    _filteredPersons = Map.fromIterable(widget.personManager.persons, key: (person) => person, value: (person) => true);
    //filteredPersons = widget.personManager.persons;
  }

  @override
  Widget build(BuildContext context) {
    _setupCompanySettingsListener(context);
    EventManager eventManager = context.read<ManagerProvider>().eventManager;
    return ChangeNotifierProvider(
      create: (_) => CalendarSettings(),
      builder: (context, __) => Scaffold(
        key: _drawerKey,
        floatingActionButton: !isMovingEvent && !isCopyingEvent && widget.user.isAdmin
            ? FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
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
          setNumberOfDays: (int days) => _setNumberOfDays(context, days),
          toggleTimeplanView: _toggleTimeplanView,
          filteredPersons: this._filteredPersons,
          didSetFilterForPersons: (person) => this._didSetFilterForPersons(eventManager, person),
          persons: widget.personManager.persons,
        ),
        body: _buildBody(eventManager),
      ),
    );
  }

  Widget _buildBody(EventManager eventManager) {
    return ProviderWidget(
      didTapEvent: this._didTapEvent,
      drawerKey: _drawerKey,
      child: isShowingTimeplan
          ? Timeplan(
              eventManager: eventManager,
              didTapEvent: _didTapEvent,
              shouldShowIsTimereported: false,
            )
          : _buildWeekPageController(context),
    );
  }

  Widget _buildWeekPageController(BuildContext context) {
    return Stack(
      children: [
        WeekPageControllerNew(
          daysChangedController: daysChangedController,
          didTapEvent: didTapEvent,
          didTapHour: _didTapHour,
          didDoubleTapHour: (date, index) => _didDoubleTapHour(context, date, index),
          didLongPressEvent: _didLongPressEvent,
        ),
        buildCopyWidget(),
      ],
    );
  }

  EventDetailScreen _buildEventDetailScreen(Event event, BuildContext context) {
    return EventDetailScreen(
      key: UniqueKey(),
      event: event,
      firebaseEventManager: widget.firebaseEventManager,
      firebaseStorageManager: firebaseStorageManager,
      didTapCopyEvent: (event) {
        HapticFeedback.lightImpact();
        setState(() {
          eventToCopy = event;
          isCopyingEvent = true;
        });
      },
      didTapChangeEvent: (event) {
        HapticFeedback.lightImpact();
        pushNewScreen(context,
            screen: AddEventScreen(
              persons: widget.personManager.persons,
              firebaseEventManager: widget.firebaseEventManager,
              firebaseStorageManager: this.firebaseStorageManager,
              eventToChange: event,
            ));
      },
    );
  }

  // MARK: Functions

  void _didTapEvent(Event event) {
    HapticFeedback.lightImpact();
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
          return _buildEventDetailScreen(event, context);
        });
  }

  void copyEvent(DateTime date, int index) {
    if (eventToCopy == null) return;
    HapticFeedback.lightImpact();
    var start = DateTime(date.year, date.month, date.day, index, eventToCopy!.start.minute);
    var diff = eventToCopy!.end.difference(eventToCopy!.start).inHours;
    var end = DateTime(date.year, date.month, date.day, index + diff, eventToCopy!.start.minute);
    eventToCopy!.start = start;
    eventToCopy!.end = end;
    eventToCopy!.timereported = [];
    widget.firebaseEventManager.addEvent(eventToCopy!);
  }

  void moveEvent(BuildContext context, DateTime date, int index) {
    EventManager eventManager = context.read<ManagerProvider>().eventManager;
    var start = DateTime(date.year, date.month, date.day, index, eventToMove!.start.minute);
    var diff = eventToMove!.end.difference(eventToMove!.start).inHours;
    var end = DateTime(date.year, date.month, date.day, index + diff, eventToMove!.start.minute);

    print("New event start: $start");
    print("New event end: $start");

    Event newEvent = eventToMove!.copyWith(start: start, end: end, isMovingEvent: eventToMove!.isMovingEvent);
    eventManager.updateEvent(key: eventToMove!.id, newEvent: newEvent, oldEvent: eventToMove!);
    setState(() {});
    HapticFeedback.heavyImpact();
  }

  Widget buildCopyWidget() {
    return isMovingEvent || isCopyingEvent
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildSmallButton(
                      title: 'Avbryt',
                      onPressed: _onTapCancel,
                      color: Colors.red,
                    ),
                  ),
                  isMovingEvent
                      ? Expanded(
                          child: _buildSmallButton(
                            title: 'Spara',
                            onPressed: _onTapSave,
                            color: Colors.green,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget _buildSmallButton({required String title, required VoidCallback onPressed, required Color color}) {
    return Container(
      height: 75,
      child: RoundedButton(
        text: title,
        fontSize: 16,
        textColor: Colors.white,
        color: color,
        onTap: onPressed,
      ),
    );
  }

  void _onTapCancel() {
    print("Tapped cancel");
    HapticFeedback.lightImpact();
    if (isMovingEvent && eventToMove != null) {
      context.read<ManagerProvider>().updateEvent(key: eventToMove!.id, newEvent: eventToMove!.copyWith(isMovingEvent: false));
    }
    setState(() {
      isCopyingEvent = false;
      isMovingEvent = false;
      eventToMove = null;
      originalEventToMove = null;
    });
  }

  void _onTapSave() {
    widget.firebaseEventManager.removeEvent(eventToMove!);
    widget.firebaseEventManager.addEvent(eventToMove!);
    setState(() {
      isCopyingEvent = false;
      isMovingEvent = false;
      eventToMove = null;
      originalEventToMove = null;
    });
  }

  void _toggleTimeplanView() {
    setState(() {
      this.isShowingTimeplan = true;
    });
    Navigator.pop(context);
  }

  void _setNumberOfDays(BuildContext context, int numberOfDays) {
    var prevNumberOfDays = CalendarSettings.of(context).numberOfDays;
    CalendarSettings.of(context).setNumberOfDays(numberOfDays);
    setState(() {
      this.isShowingTimeplan = false;
      Navigator.pop(context);
    });
    daysChangedController.daysChanged(prevNumberOfDays, numberOfDays, null);
  }

  void _applyFilterForPersons(EventManager eventManager) {
    print("Applying filter for persons");
    eventManager.eventFilter = (events) {
      return events.where((event) => event.persons?.any((p) => this._filteredPersons[p]!) ?? false).toList();
    };
  }

  void _didSetFilterForPersons(EventManager eventManager, Person person) {
    print("filter for: $person");
    setState(() {
      if (_filteredPersons[person] == null) return;
      this._filteredPersons[person] = !this._filteredPersons[person]!;
      _applyFilterForPersons(eventManager);
    });
  }

  void _setupCompanySettingsListener(BuildContext context) {
    CompanySettings companySettings = context.watch<ManagerProvider>().companySettings;
    if (companySettings.isPrivateEvents) {
      this._filteredPersons = Map<Person, bool>.fromIterable(
        widget.personManager.persons,
        key: (person) => person,
        value: (person) {
          if (widget.user.isAdmin) return true;
          if (person.id == widget.user.token)
            return true;
          else
            return false;
        },
      );
    } else {
      _filteredPersons = Map.fromIterable(widget.personManager.persons, key: (person) => person, value: (person) => true);
    }
    _applyFilterForPersons(ManagerProvider.of(context).eventManager);
    setState(() {});
  }

  void didTapEvent(Event event) {
    if (isCopyingEvent) {
      copyEvent(event.start, event.start.hour);
    } else if (isMovingEvent) {
      moveEvent(context, event.start, event.start.hour);
    } else
      this._didTapEvent(event);
  }

  void _didTapHour(DateTime date, int index) {
    if (isCopyingEvent) {
      print("upload new event at $date $index");
      copyEvent(date, index);
    } else if (isMovingEvent) {
      print("moving event");
      moveEvent(context, date, index);
    }
  }

  void _didDoubleTapHour(BuildContext context, DateTime date, int index) {
    print("Double dap date: $date");
    int numberOfDays = CalendarSettings.of(context).numberOfDays;
    if (numberOfDays == 1) {
      CalendarSettings.of(context).setNumberOfDays(7);
      daysChangedController.daysChanged(1, 7, null);
    } else {
      daysChangedController.daysChanged(7, 1, date);
      CalendarSettings.of(context).setNumberOfDays(1);
    }
  }

  void _didLongPressEvent(Event event) {
    HapticFeedback.mediumImpact();
    print("isMovingEvent: $isMovingEvent");
    context.read<ManagerProvider>().updateEvent(key: event.id, newEvent: event.copyWith(isMovingEvent: true));
    setState(() {
      this.originalEventToMove = event.copyWith();
      this.isMovingEvent = !this.isMovingEvent;
      this.eventToMove = (eventToMove == null ? event : null);
    });
  }
}
