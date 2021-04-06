import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/screens/TimeReporting/timereporting_screen.dart';
import '../network/firebase_event_manager.dart';
import '../network/firebase_user_manager.dart';
import '../network/firebase_person_manager.dart';
import '../utils/event_manager.dart';
import '../utils/person_manager.dart';
import './settings_screen.dart';
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
  EventManager eventManager;
  PersonManager personManager;
  bool loading = true;
  PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    firebaseUserManager = FirebaseUserManager();

    firebaseUserManager.getUser().then((user) {
      this.user = user;
      firebasePersonManager = FirebasePersonManager(company: user.company);
      firebasePersonManager.getPersons().then((persons) {
        personManager = PersonManager(persons: persons);
        setState(() {
          loading = false;
        });
      });
    });
  }

  List<Widget> _buildScreens() {
    return loading
        ? [
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            TimeReportingScreen(),
            Container()
          ]
        : [
            CalendarScreen(
              user: user,
              personManager: personManager,
            ),
            TimeReportingScreen(),
            SettingsScreen()
          ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.calendar_today),
        title: ("Kalender"),
        activeColor: Colors.lightBlue,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.timer),
        title: ("Tidrapportering"),
        activeColor: Colors.lightBlue,
        inactiveColor: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Verktyg"),
        activeColor: Colors.lightBlue,
        inactiveColor: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
        overlayWidget: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
        ),
        overlayOpacity: 0.8,
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.white,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset:
              true, // This needs to be true if you want to move up the screen when keyboard appears.
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows:
              true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
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
              .style2, // Choose the nav bar style with this property.
        ));
  }
}
