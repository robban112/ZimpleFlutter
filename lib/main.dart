import 'package:zimple/model/person.dart';
import 'package:zimple/screens/Calendar/add_event_screen.dart';
import 'package:zimple/screens/Calendar/person_select_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_screen.dart';
import 'package:zimple/screens/settings_screen.dart';
import 'package:zimple/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:zimple/screens/welcome_screen.dart';
import 'screens/Calendar/add_event_screen.dart';
import 'screens/login_screen.dart';
import 'screens/Calendar/calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/tab_bar_controller.dart';

import 'package:firebase_core/firebase_core.dart';

import 'screens/tab_bar_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   FirebaseApp
//   runApp(MaterialApp(
//     title: 'Flutter Database Example',
//     home: Zimple(app: app),
//   ));
// }

class Zimple extends StatefulWidget {
  @override
  _ZimpleState createState() => _ZimpleState();
}

class _ZimpleState extends State<Zimple> {
  List<Person> mockperson = [
    Person(name: "Zebbe", color: Colors.blue, id: "0"),
    Person(name: "Zebbe1", color: Colors.blue, id: "1"),
    Person(name: "Zebbe2", color: Colors.blue, id: "2")
  ];
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('sv_SE');
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Montserrat', accentColor: Colors.lightBlue),
      initialRoute: TabBarController.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
        CalendarScreen.routeName: (context) => CalendarScreen(),
        TabBarController.routeName: (context) => TabBarController(),
        TodoScreen.routeName: (context) => TodoScreen(),
        SettingsScreen.routeName: (context) => SettingsScreen(),
        AddEventScreen.routeName: (context) =>
            AddEventScreen(persons: mockperson),
        PersonSelectScreen.routeName: (context) =>
            PersonSelectScreen(persons: mockperson),
        TimeReportingScreen.routeName: (context) => TimeReportingScreen(),
      },
    );
  }
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _init = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: _init,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Zimple();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}
