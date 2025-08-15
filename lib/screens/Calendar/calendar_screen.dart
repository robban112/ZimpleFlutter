import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:zimple/components/timeplan.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/screens/Calendar/Filter/filter_persons_page.dart';
import 'package:zimple/screens/Calendar/Onboarding/onboarding_screen.dart';
import 'package:zimple/screens/drawer.dart';
import 'package:zimple/utils/zpreferences.dart';
import 'package:zimple/widgets/button/event_modify_buttons.dart';
import 'package:zimple/widgets/floating_add_button.dart';
import 'package:zimple/widgets/provider_widget.dart';

import '../../components/week_page_controller_new.dart';
import '../../managers/event_manager.dart';
import '../../managers/person_manager.dart';
import '../../network/firebase_event_manager.dart';
import '../../network/firebase_user_manager.dart';
import '../../utils/date_utils.dart';
import '../../utils/days_changed_controller.dart';
import 'AddEvent/add_event_screen.dart';
import 'event_detail_screen.dart';

class CalendarSettings extends ChangeNotifier {
  double minuteHeight = 0.6;

  bool shouldSkipWeekends = false;

  int numberOfDays = 7;

  bool canFilter = false;

  Future<void> init() async {
    this.shouldSkipWeekends = await ZPreferences.readData<bool>(Keys.calendarIsShowingWeekend) ?? true;
  }

  void setNumberOfDays(int numberOfDays) {
    this.numberOfDays = numberOfDays;
    notifyListeners();
  }

  Future<void> setShouldSkipWeekend(bool skip) async {
    this.shouldSkipWeekends = skip;
    await ZPreferences.saveData<bool>(Keys.calendarIsShowingWeekend, skip);
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

  Event? eventToModify;

  bool isShowingTimeplan = false;

  bool viewingMySchedule = false;

  bool isMovingEvent = false;

  bool isShowingEventOptions = false;

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
    _applyFilterForPersons(ManagerProvider.of(context).eventManager);
    maybeShowOnboarding();
    Future.delayed(Duration.zero, () {
      initFilteredPersons();
      _handleEventMessage(); // Handle first message if there are any
      ManagerProvider.of(context).eventIdMessageOpen.addListener(() {
        // setup on message opened listener
        _handleEventMessage();
      });
      //_setupCompanySettingsListener(context);
    });
  }

  void _handleEventMessage() {
    var eventId = ManagerProvider.of(context).eventIdMessageOpen.value;
    if (eventId == null) return;
    var event = EventManager.of(context).getEventForKey(key: eventId);
    print("Event to open from push notification: $event");
    if (event != null) _didTapEvent(event);
  }

  void maybeShowOnboarding() async {
    await Future.delayed(Duration(milliseconds: 500), () async {
      bool? hasSeenIntroduction = await ZPreferences.readData(Keys.hasSeenOnboarding);
      if (hasSeenIntroduction != true) {
        showCupertinoModalPopup(context: context, builder: (context) => OnboardingScreen());
        ZPreferences.saveData(Keys.hasSeenOnboarding, true);
      }
    });
  }

  Future<void> initFilteredPersons() async {
    List<String>? savedSelectedPersons = await ZPreferences.getStringList(Keys.calendarFilteredPersons);
    CompanySettings companySettings = CompanySettings.of(context);
    if (companySettings.isPrivateEvents && !widget.user.isAdmin) {
      // Filter only this user

      _filteredPersons = Map<Person, bool>.fromIterable(
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
    } else if (savedSelectedPersons != null) {
      // Filter all saved users

      _filteredPersons.keys.forEach((person) {
        if (savedSelectedPersons.contains(person.id)) {
          setState(() => _filteredPersons[person] = true);
        } else {
          setState(() => _filteredPersons[person] = false);
        }
      });
    } else {
      _filteredPersons = Map.fromIterable(widget.personManager.persons, key: (person) => person, value: (person) => true);
    }
    _applyFilterForPersons(ManagerProvider.of(context).eventManager);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    EventManager eventManager = context.read<ManagerProvider>().eventManager;
    return Scaffold(
      key: _drawerKey,
      floatingActionButton: !isShowingEventOptions && !isMovingEvent && !isCopyingEvent && widget.user.isAdmin
          ? FloatingAddButton(
              onPressed: _goToAddEvent,
            )
          : Container(),
      drawer: DrawerWidget(
        setNumberOfDays: (int days) => _setNumberOfDays(context, days),
        toggleTimeplanView: _toggleTimeplanView,
        filteredPersons: this._filteredPersons,
        didSetFilterForPersons: (person) => this._didSetFilterForPersons(eventManager, person),
        persons: widget.personManager.persons,
        isPrivateEvents: CompanySettings.of(context).isPrivateEvents,
      ),
      body: _buildBody(context, eventManager),
    );
  }

  Widget _buildBody(BuildContext context, EventManager eventManager) {
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
          onTapFilter: showFilterPage,
          daysChangedController: daysChangedController,
          didTapEvent: didTapEvent,
          didTapHour: _didTapHour,
          didDoubleTapHour: (date, index) => _didDoubleTapHour(context, date, index),
          didLongPressEvent: _didLongPressEvent,
        ),
        EventModifyButtons(
          visible: isShowingEventOptions,
          onTapCancel: () => setState(() {
            isShowingEventOptions = false;
            eventToModify = null;
          }),
          onTapChange: () => _didTapChangeEvent(eventToModify),
          onTapCopy: () => _didTapCopyEvent(eventToModify),
          onTapMove: () => _moveEvent(eventToModify),
          onTapDelete: () => _didTapRemoveEvent(eventToModify),
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
      didTapCopyEvent: _didTapCopyEvent,
      didTapChangeEvent: _didTapChangeEvent,
      didTapRemoveEvent: _didTapRemoveEvent,
    );
  }

  void _didTapCopyEvent(Event? event) {
    _exitModifyEvent();
    if (event == null) return;
    HapticFeedback.lightImpact();
    setState(() {
      eventToCopy = event;
      isCopyingEvent = true;
    });
  }

  void _didTapChangeEvent(Event? event) {
    _exitModifyEvent();
    if (event == null) return;
    HapticFeedback.lightImpact();
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: AddEventScreen(
        persons: widget.personManager.persons,
        firebaseEventManager: widget.firebaseEventManager,
        firebaseStorageManager: this.firebaseStorageManager,
        eventToChange: event,
      ),
    );
  }

  void _exitModifyEvent() => setState(() => isShowingEventOptions = false);

  void _didTapRemoveEvent(Event? event) {
    _exitModifyEvent();
    if (event == null) return;
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text("Ta bort arbetsorder"),
              content: new Text("Är du säker på att du vill ta bort den här arbetsordern?"),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text("Ja"),
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop();
                      widget.firebaseEventManager.removeEvent(event);
                    }),
                CupertinoDialogAction(
                  child: Text("Nej"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
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
    double width = MediaQuery.of(context).size.width;
    double cancelButtonWidth = isMovingEvent ? (width / 2) - 24 : width - 32;
    return isMovingEvent || isCopyingEvent
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ZButton(onTap: _onTapCancel, text: "Avbryt", type: ZButtonType.red, width: cancelButtonWidth),
                  if (isMovingEvent) SizedBox(width: 16),
                  isMovingEvent
                      ? ZButton(onTap: _onTapSave, text: "Spara", type: ZButtonType.green, width: cancelButtonWidth)
                      : Container(),
                ],
              ),
            ),
          )
        : Container();
  }

  void showFilterPage() {
    showCupertinoDialog(
      context: context,
      builder: (context) => FilterPersonsPage(
        preSelectedPersons: _filteredPersons,
        selected: (selected) {
          this._filteredPersons.keys.forEach((person) {
            this._filteredPersons[person] = selected.contains(person);
          });
          setState(() {});
          ZPreferences.saveData(Keys.calendarFilteredPersons, selectedPersons());
        },
      ),
    );
  }

  void _goToAddEvent() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEventScreen(
            persons: widget.personManager.persons,
            firebaseEventManager: widget.firebaseEventManager,
            firebaseStorageManager: this.firebaseStorageManager,
          ),
        ));
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
      List<Event> eventsToShow = [];
      for (Event event in events) {
        if (event.persons == null || event.persons!.isEmpty) {
          eventsToShow.add(event);
        } else if (event.persons!.any((Person person) => this._filteredPersons[person]!)) {
          eventsToShow.add(event);
        }
      }
      return eventsToShow;
    };
  }

  void _didSetFilterForPersons(EventManager eventManager, Person person) {
    print("filter for: $person");
    setState(() {
      if (_filteredPersons[person] == null) return;
      print(_filteredPersons);
      this._filteredPersons[person] = !this._filteredPersons[person]!;
      _applyFilterForPersons(eventManager);
    });
    ZPreferences.saveData(Keys.calendarFilteredPersons, selectedPersons());
  }

  List<String> selectedPersons() => this
      ._filteredPersons
      .keys
      .map((person) {
        if (_filteredPersons[person]!)
          return person;
        else
          return null;
      })
      .whereType<Person>()
      .map((Person person) => person.id)
      .toList();

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
    setState(() {
      isShowingEventOptions = true;
      eventToModify = event;
    });
  }

  void _moveEvent(Event? event) {
    _exitModifyEvent();
    if (event == null) return;
    print("isMovingEvent: $isMovingEvent");
    context.read<ManagerProvider>().updateEvent(key: event.id, newEvent: event.copyWith(isMovingEvent: true));
    setState(() {
      this.originalEventToMove = event.copyWith();
      this.isMovingEvent = !this.isMovingEvent;
      this.eventToMove = (eventToMove == null ? event : null);
    });
  }
}
