import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_screen.dart';
import 'package:zimple/screens/Settings/settings_screen.dart';
import 'package:zimple/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'screens/Login/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/tab_bar_controller.dart';

import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

Future<dynamic> _firebaseMessagingBackgroundHandler(
  Map<String, dynamic> message,
) async {
  // Initialize the Firebase app
  await Firebase.initializeApp();
  print('onBackgroundMessage received: $message');
}

Future<bool> isUserLoggedIn() async {
  // FirebaseAuth.instance.authStateChanges().listen((user) {
  //   if (user == null) {
  //     print("User is currently signed out");
  //   } else {
  //     print("User is signed in");
  //   }
  // });
  User firebaseUser = getLoggedInFirebaseUser();
  if (firebaseUser != null) {
    String tokenResult = await firebaseUser.getIdToken(true);
    return tokenResult != null;
  } else {
    return false;
  }
}

User getLoggedInFirebaseUser() {
  return FirebaseAuth.instance.currentUser;
}

class Zimple extends StatefulWidget {
  final bool isLoggedIn;
  Zimple(this.isLoggedIn);
  @override
  _ZimpleState createState() => _ZimpleState();
}

class _ZimpleState extends State<Zimple> {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('sv_SE');
    return ChangeNotifierProvider(
      create: (_) => ManagerProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins', accentColor: green),
        initialRoute: widget.isLoggedIn
            ? TabBarController.routeName
            : LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          TabBarController.routeName: (context) => TabBarController(),
          TodoScreen.routeName: (context) => TodoScreen(),
          SettingsScreen.routeName: (context) => SettingsScreen(),
          TimeReportingScreen.routeName: (context) => TimeReportingScreen(),
          ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen()
        },
      ),
    );
  }
}

Future<bool> initializeApp() async {
  await Firebase.initializeApp();
  return isUserLoggedIn();
}

class App extends StatelessWidget {
  final Future<bool> _init = initializeApp();
  //final Future<bool> _isLoggedIn = isUserLoggedIn();
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
          return Zimple(snapshot.data);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}
