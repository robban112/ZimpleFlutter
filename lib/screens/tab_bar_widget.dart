import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_company_manager.dart';
import 'package:zimple/network/firebase_contact_manager.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/network/firebase_drive_record_manager.dart';
import 'package:zimple/network/firebase_notes_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:zimple/screens/Economy/economy_screen.dart';
import 'package:zimple/screens/Login/login_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_screen.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/utils/utils.dart';
import 'package:zimple/widgets/provider_widget.dart';

import '../managers/event_manager.dart';
import '../managers/person_manager.dart';
import '../network/firebase_event_manager.dart';
import '../network/firebase_person_manager.dart';
import '../network/firebase_user_manager.dart';
import 'Settings/more_screen.dart';

class TabBarWidget extends StatefulWidget {
  static final routeName = "tab_bar_screen";
  @override
  _TabBarControllerState createState() => _TabBarControllerState();
}

class _TabBarControllerState extends State<TabBarWidget> with TickerProviderStateMixin<TabBarWidget> {
  //final _navigatorKey = GlobalKey<NavigatorState>();

  late String userName;
  late String userToken;
  late UserParameters user;
  late FirebaseEventManager firebaseEventManager;
  FirebaseUserManager firebaseUserManager = FirebaseUserManager();
  late FirebasePersonManager firebasePersonManager;
  late FirebaseCustomerManager firebaseCustomerManager;
  EventManager eventManager = EventManager(events: []);
  PersonManager personManager = PersonManager(persons: []);
  CustomerManager customerManager = CustomerManager(customers: []);
  bool loadingEvent = true;
  bool loadingTimereport = true;
  PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  late StreamSubscription<EventManager> eventManagerSubscriber;
  late StreamSubscription<List<Customer>> customerSubscriber;
  late StreamSubscription<List<Contact>> contactSubscriber;
  late StreamSubscription<List<Person>> personSubscriber;
  late StreamSubscription<TimereportManager> timereportStream;
  late StreamSubscription<CompanySettings> companySettingsStream;
  late ManagerProvider managerProvider;
  TimereportManager timeReportManager = TimereportManager();
  bool loading = true;
  bool hasLoggedOut = false;

  _TabBarControllerState();

  @override
  void initState() {
    managerProvider = Provider.of<ManagerProvider>(context, listen: false);
    managerProvider.firebaseUserManager = firebaseUserManager;
    setupUser();
    super.initState();
  }

  Future<void> setupUser() async {
    firebaseUserManager.getUser()?.then((user) {
      //Utils.setLoading(context, true);
      _setupUser(user);
      _setupManagers(user.company);

      updateFCMToken(user);
      setupCustomerSubscriber();
      setupContactListener(user);

      FirebaseCompanyManager firebaseCompanyManager = FirebaseCompanyManager(company: user.company);
      managerProvider.firebaseCompanyManager = firebaseCompanyManager;
      setupCompanySubscriber(firebaseCompanyManager);

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
        managerProvider.initProfilePictureService();
        setupFirebaseEventManager();
        setupFirebaseTimereport();
        setupPersonsListener();
        setupNotesManager();
        setupDriveJournalManager();
      });
    });
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
    timereportStream = firebaseTimeReportManager.listenTimereports(user).listen((timereportManager) {
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

  void setupCompanySubscriber(FirebaseCompanyManager firebaseCompanyManager) {
    companySettingsStream = firebaseCompanyManager.streamCompanySettings().listen(
          (CompanySettings companySettings) => managerProvider.updateCompanySettings(
            companySettings: companySettings,
          ),
        );
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
      eventManager.eventFilter = this.eventManager.eventFilter;
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

  void setupNotesManager() {
    managerProvider.firebaseNotesManager = FirebaseNotesManager(
      company: user.company,
      personManager: personManager,
    );
  }

  void setupDriveJournalManager() {
    managerProvider.firebaseDriveJournalManager = FirebaseDriveJournalManager(
      company: user.company,
      personManager: personManager,
    );
  }

  @override
  void dispose() {
    cancelStreams();
    super.dispose();
  }

  Future<void> cancelStreams() async {
    await eventManagerSubscriber.cancel();
    await customerSubscriber.cancel();
    await contactSubscriber.cancel();
    await personSubscriber.cancel();
    await timereportStream.cancel();
    await companySettingsStream.cancel();
    managerProvider.dispose();
  }

  Future<void> onLogout(BuildContext context) async {
    cancelStreams();
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  List<Widget> _buildScreens(BuildContext context) {
    CalendarSettings calendarSettings = CalendarSettings()..init();
    return loadingEvent && loadingTimereport
        ? [
            _loadingWidget(context),
            _loadingWidget(context),
            _loadingWidget(context),
            _loadingWidget(context),
          ]
        : [
            ChangeNotifierProvider(
              create: (_) => calendarSettings,
              builder: (context, _) => CalendarScreen(
                user: user,
                personManager: personManager,
                firebaseEventManager: firebaseEventManager,
              ),
            ),
            TimeReportingScreen(
              eventManager: eventManager,
              personManager: personManager,
              user: user,
            ),
            EconomyScreen(),
            MoreScreen(
              user: this.user,
              onLogout: () => onLogout(context),
            )
          ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    double size = 22;
    Color inactiveColor = Colors.grey;
    Color activeColor = ThemeNotifier.of(context).green;
    //Color activeColor = Color.fromARGB(255, 90, 71, 156);
    return [
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.calendar, size: size),
        title: ("Planera"),
        activeColorPrimary: Color(0xff7CD8EC),
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.clock, size: size),
        title: ("Rapportera"),
        activeColorPrimary: ThemeNotifier.of(context).yellow,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FontAwesomeIcons.coins, size: size),
        title: ("Ekonomi"),
        activeColorPrimary: ThemeNotifier.of(context).green,
        inactiveColorPrimary: inactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FeatherIcons.settings, size: size),
        title: ("Mer"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: inactiveColor,
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
            overlayWidgetBuilder: (_) => CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).bottomNavigationBarTheme.backgroundColor!),
                ),
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
                  //backgroundColor: Color(0xffF4F7FB),
                  backgroundColor: ThemeNotifier.darkThemePrimaryBg,
                  handleAndroidBackButtonPress: true,
                  resizeToAvoidBottomInset:
                      true, // This needs to be true if you want to move up the screen when keyboard appears.
                  stateManagement: true,
                  decoration: NavBarDecoration(
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(7),
                    //   topRight: Radius.circular(7),
                    // ),
                    border: Border(top: BorderSide(color: ThemeNotifier.of(context).textColor, width: 0.1)),
                    colorBehindNavBar: Colors.white,
                  ),
                  navBarHeight: kBottomNavigationBarHeight,

                  navBarStyle: NavBarStyle.style12, // Choose the nav bar style with this property.
                ),
              ],
            ));
  }
}
