import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/customer_manager.dart';
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
  late CustomerManager customerManager;
  bool loadingEvent = true;
  bool loadingTimereport = true;
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  late StreamSubscription<EventManager> eventManagerSubscriber;
  late StreamSubscription<List<Customer>> customerSubscriber;
  late StreamSubscription<List<Contact>> contactSubscriber;
  late StreamSubscription<List<Person>> personSubscriber;
  late ManagerProvider managerProvider;
  TimereportManager timeReportManager = TimereportManager();
  bool loading = true;

  _TabBarControllerState();

  @override
  void initState() {
    managerProvider = Provider.of<ManagerProvider>(context, listen: false);
    managerProvider.firebaseUserManager = firebaseUserManager;
    firebaseUserManager.getUser()?.then((user) {
      //Utils.setLoading(context, true);
      _setupUser(user);
      _setupManagers(user.company);

      updateFCMToken(user);
      setupCustomerSubscriber();
      setupContactListener(user);

      Future.wait([
        firebaseCustomerManager.getCustomers(),
        firebasePersonManager.getPersons(),
      ]).then((List responses) {
        List<Person> persons = responses[1] as List<Person>;
        List<Customer> customers = responses[0] as List<Customer>;
        print("Received persons: ${persons.toString()}");
        print("Received customers: ${customers.toString()}");
        CustomerManager customerManager = CustomerManager(customers: customers);
        managerProvider.customerManager = customerManager;
        managerProvider.customers = customers;
        setState(() {
          loading = false;
        });
        setupPersonManager(persons);
        setupFirebaseEventManager();
        setupFirebaseTimereport();
        setupPersonsListener();
      });
    });
    super.initState();
  }

  _setupUser(UserParameters user) {
    this.user = user;
    managerProvider.user = user;
  }

  _setupManagers(String company) {
    firebaseCustomerManager = FirebaseCustomerManager(company: company);
    firebasePersonManager = FirebasePersonManager(company: company);

    managerProvider.firebaseCustomerManager = firebaseCustomerManager;
    managerProvider.firebasePersonManager = firebasePersonManager;
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

  void setupPersonsListener() {
    personSubscriber = managerProvider.firebasePersonManager.listenPersons().listen((event) {
      managerProvider.setPersons(event);
    });
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
        // if (!loadingTimereport && !loadingEvent) Utils.setLoading(context, false);
      });

      //print(timereportManager.getTimereports(user.token).first.breakTime);
    });
  }

  void setupCustomerSubscriber() {
    customerSubscriber = firebaseCustomerManager.listenCustomers().listen((customers) {
      setState(() {
        managerProvider.customers = customers;
        this.customerManager = CustomerManager(customers: customers);
      });
    });
  }

  void setupFirebaseEventManager() {
    firebaseEventManager = FirebaseEventManager(
      company: user.company,
      personManager: this.personManager,
      customerManager: this.customerManager,
    );
    managerProvider.firebaseEventManager = firebaseEventManager;
    eventManagerSubscriber = firebaseEventManager.listenEvents().listen((eventManager) {
      if (!mounted) return;
      setState(() {
        this.eventManager = eventManager;
        managerProvider.setEventManager(eventManager);
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
    managerProvider.dispose();
    contactSubscriber.cancel();
    personSubscriber.cancel();
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
            ),
            TimeReportingScreen(
              eventManager: eventManager,
              personManager: personManager,
              user: user,
            ),
            MoreScreen(
              user: this.user,
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
                    duration: Duration(milliseconds: 150),
                    curve: Curves.ease,
                  ),
                  screenTransitionAnimation: ScreenTransitionAnimation(
                    // Screen transition animation on change of selected tab.
                    animateTabTransition: false,
                  ),
                  navBarStyle: NavBarStyle.style8, // Choose the nav bar style with this property.
                ),
              ],
            ));
  }
}
