import 'dart:async';
import 'dart:ffi';

import 'package:provider/provider.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/screens/TimeReporting/timereporting_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../network/firebase_event_manager.dart';
import '../network/firebase_user_manager.dart';
import '../network/firebase_person_manager.dart';
import '../managers/event_manager.dart';
import '../managers/person_manager.dart';
import 'Settings/settings_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class TabBarController extends StatefulWidget {
  static final routeName = "tab_bar_screen";
  @override
  _TabBarControllerState createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarController>
    with TickerProviderStateMixin<TabBarController> {
  //final _navigatorKey = GlobalKey<NavigatorState>();

  String userName;
  String userToken;
  UserParameters user;
  FirebaseEventManager firebaseEventManager;
  FirebaseUserManager firebaseUserManager;
  FirebasePersonManager firebasePersonManager;
  FirebaseCustomerManager firebaseCustomerManager;
  EventManager eventManager;
  PersonManager personManager;
  bool loadingEvent = true;
  bool loadingTimereport = true;
  PersistentTabController _controller;
  StreamSubscription<EventManager> eventManagerSubscriber;
  StreamSubscription<Void> timereportSubscriper;
  StreamSubscription<List<Customer>> customerSubscriber;
  ManagerProvider managerProvider;
  TimereportManager timeReportManager;
  List<Customer> customers;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    firebaseUserManager = FirebaseUserManager();
    managerProvider = Provider.of<ManagerProvider>(context, listen: false);

    firebaseUserManager.getUser().then((user) {
      this.user = user;
      managerProvider.user = user;

      setupCustomerSubscriber();
      managerProvider.firebaseCustomerManager = firebaseCustomerManager;
      firebasePersonManager = FirebasePersonManager(company: user.company);
      firebasePersonManager.getPersons().then((persons) {
        setupPersonManager(persons);
        setupFirebaseEventManager();
        setupFirebaseTimereport();
      });
    });
  }

  void setupFirebaseTimereport() {
    FirebaseTimeReportManager firebaseTimeReportManager =
        FirebaseTimeReportManager(
            company: user.company, personManager: personManager);
    managerProvider.firebaseTimereportManager = firebaseTimeReportManager;
    managerProvider.timereportManager = TimereportManager();
    firebaseTimeReportManager
        .listenTimereports(user)
        .listen((timereportManager) {
      print("listen new timereport");
      setState(() {
        this.timeReportManager = timeReportManager;
        this.loadingTimereport = false;
      });
      managerProvider.timereportManager = timereportManager;
      //print(timereportManager.getTimereports(user.token).first.breakTime);
    });
  }

  void setupCustomerSubscriber() {
    firebaseCustomerManager = FirebaseCustomerManager(company: user.company);
    customerSubscriber =
        firebaseCustomerManager.listenCustomers().listen((customers) {
      setState(() {
        managerProvider.customers = customers;
        this.customers = customers;
      });
    });
  }

  void setupFirebaseEventManager() {
    firebaseEventManager = FirebaseEventManager(
        company: user.company, personManager: personManager);
    managerProvider.firebaseEventManager = firebaseEventManager;
    eventManagerSubscriber =
        firebaseEventManager.listenEvents().listen((eventManager) {
      if (!mounted) return;
      setState(() {
        this.eventManager = eventManager;
        managerProvider.eventManager = eventManager;
        loadingEvent = false;
      });
    });
  }

  void setupPersonManager(List<Person> persons) {
    personManager = PersonManager(persons: persons);
    managerProvider.personManager = personManager;
  }

  @override
  void dispose() {
    super.dispose();
    eventManagerSubscriber.cancel();
    customerSubscriber.cancel();
  }

  List<Widget> _buildScreens() {
    return loadingEvent && loadingTimereport
        ? [
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              ),
            ),
            Container(),
            Container()
          ]
        : [
            CalendarScreen(
              user: user,
              personManager: personManager,
              firebaseEventManager: firebaseEventManager,
              eventManager: eventManager,
            ),
            TimeReportingScreen(
              eventManager: eventManager,
              personManager: personManager,
              user: user,
            ),
            SettingsScreen(
              user: this.user,
              customers: this.customers,
            )
          ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_today),
        title: ("Kalender"),
        activeColor: Colors.lightBlueAccent,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.timer),
        title: ("Tidrapportering"),
        activeColor: Colors.lightBlueAccent,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Verktyg"),
        activeColor: Colors.lightBlueAccent,
        inactiveColor: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        overlayWidget: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(green),
        ),
        overlayOpacity: 0.8,
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Color(0xffF4F7FB),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset:
              false, // This needs to be true if you want to move up the screen when keyboard appears.
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows:
              true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          navBarHeight: 55,
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle
              .style8, // Choose the nav bar style with this property.
        ));
  }
}
