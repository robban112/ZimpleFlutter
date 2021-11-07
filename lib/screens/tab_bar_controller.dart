import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_contact_manager.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/screens/TimeReporting/timereporting_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/utils.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../network/firebase_event_manager.dart';
import '../network/firebase_user_manager.dart';
import '../network/firebase_person_manager.dart';
import '../managers/event_manager.dart';
import '../managers/person_manager.dart';
import 'Settings/more_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class TabBarController extends StatefulWidget {
  static final routeName = "tab_bar_screen";
  @override
  _TabBarControllerState createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarController> with TickerProviderStateMixin<TabBarController> {
  //final _navigatorKey = GlobalKey<NavigatorState>();

  late String userName;
  late String userToken;
  late UserParameters user;
  late FirebaseEventManager firebaseEventManager;
  FirebaseUserManager firebaseUserManager = FirebaseUserManager();
  late FirebasePersonManager firebasePersonManager;
  late FirebaseCustomerManager firebaseCustomerManager;
  late EventManager eventManager;
  late PersonManager personManager;
  bool loadingEvent = true;
  bool loadingTimereport = true;
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  late StreamSubscription<EventManager> eventManagerSubscriber;
  late StreamSubscription timereportSubscriper;
  late StreamSubscription<List<Customer>> customerSubscriber;
  late StreamSubscription<List<Contact>> contactSubscriber;
  late ManagerProvider managerProvider;
  TimereportManager timeReportManager = TimereportManager();
  late List<Customer> customers;
  bool loading = true;

  _TabBarControllerState();

  @override
  void initState() {
    managerProvider = Provider.of<ManagerProvider>(context, listen: false);
    managerProvider.firebaseUserManager = firebaseUserManager;
    firebaseUserManager.getUser()?.then((user) {
      setState(() {
        loading = false;
      });
      //Utils.setLoading(context, true);
      this.user = user;
      managerProvider.user = user;
      updateFCMToken(user);
      setupCustomerSubscriber();
      setupContactListener(user);
      managerProvider.firebaseCustomerManager = firebaseCustomerManager;
      firebasePersonManager = FirebasePersonManager(company: user.company);
      managerProvider.firebasePersonManager = firebasePersonManager;
      firebasePersonManager.getPersons().then((persons) {
        setupPersonManager(persons);
        setupFirebaseEventManager();
        setupFirebaseTimereport();
      });
    });
    super.initState();
  }

  Future<String?> getTokenz() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    return token;
  }

  void updateFCMToken(UserParameters user) async {
    String? token = await getTokenz();
    if (token == null) return;
    if (user.fcmToken != token) {
      print("Updating user fcm token");
      firebaseUserManager.setUserFCMToken(user, token);
    }
  }

  void listenToUserTopic() {
    print("listening to topic: ${this.user.token}");
    FirebaseMessaging.instance.subscribeToTopic(this.user.token);
  }

  void setupContactListener(UserParameters user) {
    FirebaseContactManager firebaseContactManager = FirebaseContactManager(user.company);
    managerProvider.firebaseContactManager = firebaseContactManager;
    contactSubscriber = firebaseContactManager.listenContacts().listen((event) {
      print("Listening new contacts");
      managerProvider.setContacts(event);
    });
  }

  void setupFirebaseTimereport() {
    FirebaseTimeReportManager firebaseTimeReportManager =
        FirebaseTimeReportManager(company: user.company, personManager: personManager);
    managerProvider.firebaseTimereportManager = firebaseTimeReportManager;
    managerProvider.timereportManager = TimereportManager();
    timeReportManager = TimereportManager();
    firebaseTimeReportManager.listenTimereports(user).listen((timereportManager) {
      print("listen new timereport");
      setState(() {
        this.timeReportManager = timeReportManager;
        managerProvider.timereportManager = timereportManager;
        this.loadingTimereport = false;
        if (!loadingTimereport && !loadingEvent) Utils.setLoading(context, false);
      });

      //print(timereportManager.getTimereports(user.token).first.breakTime);
    });
  }

  void setupCustomerSubscriber() {
    firebaseCustomerManager = FirebaseCustomerManager(company: user.company);
    customerSubscriber = firebaseCustomerManager.listenCustomers().listen((customers) {
      setState(() {
        managerProvider.customers = customers;
        this.customers = customers;
      });
    });
  }

  void setupFirebaseEventManager() {
    firebaseEventManager = FirebaseEventManager(company: user.company, personManager: personManager);
    managerProvider.firebaseEventManager = firebaseEventManager;
    eventManagerSubscriber = firebaseEventManager.listenEvents().listen((eventManager) {
      if (!mounted) return;
      setState(() {
        this.eventManager = eventManager;
        managerProvider.eventManager = eventManager;
        loadingEvent = false;
        if (!loadingTimereport && !loadingEvent) Utils.setLoading(context, false);
      });
    });
  }

  void setupPersonManager(List<Person> persons) {
    personManager = PersonManager(persons: persons);
    managerProvider.personManager = personManager;
  }

  @override
  void dispose() {
    eventManagerSubscriber.cancel();
    customerSubscriber.cancel();
    timereportSubscriper.cancel();
    managerProvider.dispose();
    contactSubscriber.cancel();
    super.dispose();
  }

  List<Widget> _buildScreens(BuildContext context) {
    return loadingEvent && loadingTimereport
        ? [_loadingWidget(context), _loadingWidget(context), _loadingWidget(context)]
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
            MoreScreen(
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
        activeColorPrimary: Theme.of(context).colorScheme.secondary,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.timer),
        title: ("Tidrapportering"),
        activeColorPrimary: Theme.of(context).colorScheme.secondary,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.more_horiz),
        title: ("Mer"),
        activeColorPrimary: Theme.of(context).colorScheme.secondary,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  Widget _loadingWidget(BuildContext context) => Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor)
        : LoaderOverlay(
            overlayWidget: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
            overlayOpacity: 0.0,
            child: Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Theme.of(context).primaryColor),
                PersistentTabView(
                  context,
                  controller: _controller,
                  screens: _buildScreens(context),
                  items: _navBarsItems(),
                  confineInSafeArea: true,
                  //backgroundColor: Color(0xffF4F7FB),
                  backgroundColor: Theme.of(context).bottomAppBarColor,
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
                  navBarStyle: NavBarStyle.style8, // Choose the nav bar style with this property.
                ),
              ],
            ));
  }
}
