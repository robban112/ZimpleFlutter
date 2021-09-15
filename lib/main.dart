import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'screens/Login/login_screen.dart';
import 'screens/tab_bar_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: App(),
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

// Future<dynamic> _firebaseMessagingBackgroundHandler(
//   Map<String, dynamic> message,
// ) async {
//   // Initialize the Firebase app
//   await Firebase.initializeApp();
//   print('onBackgroundMessage received: $message');
// }

Future<bool> isUserLoggedIn() async {
  // FirebaseAuth.instance.authStateChanges().listen((user) {
  //   if (user == null) {
  //     print("User is currently signed out");
  //   } else {
  //     print("User is signed in");
  //   }
  // });
  User? firebaseUser = getLoggedInFirebaseUser();
  if (firebaseUser != null) {
    String tokenResult = await firebaseUser.getIdToken(true);
    return true;
  } else {
    return false;
  }
}

User? getLoggedInFirebaseUser() {
  return FirebaseAuth.instance.currentUser;
}

class Zimple extends StatefulWidget {
  final bool isLoggedIn;
  Zimple(this.isLoggedIn);
  @override
  _ZimpleState createState() => _ZimpleState();
}

class _ZimpleState extends State<Zimple> {
  //FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    askPermissionForPush();
    super.initState();
  }

  void askPermissionForPush() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("PUSH RECEIVED");
      //bFirebaseMessaging.showPush(message);
    });

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _throwGetMessage(RemoteMessage message) async {
    print("PUSH RECEIVED");
    //await Firebase.initializeApp();
    //bFirebaseMessaging.showPushFromBackground(message);
  }

  @override
  Widget build(BuildContext context) {
    //initializeDateFormatting('sv_se');
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white),
    );

    FirebaseMessaging.onBackgroundMessage(_throwGetMessage);
    return ChangeNotifierProvider(
      create: (_) => ManagerProvider(),
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => MaterialApp(
          localizationsDelegates: [GlobalCupertinoLocalizations.delegate, GlobalMaterialLocalizations.delegate],
          supportedLocales: [const Locale('sv', 'SV')],
          locale: Locale.fromSubtags(languageCode: 'sv'),
          debugShowCheckedModeBanner: false,
          theme: theme.getTheme(),
          // theme: ThemeData(
          //   fontFamily: 'FiraSans',
          //   accentColor: green,
          //   focusColor: green,
          //   scaffoldBackgroundColor: backgroundColor,
          // ),
          initialRoute: widget.isLoggedIn ? TabBarController.routeName : LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            TabBarController.routeName: (context) => TabBarController(),
            // SettingsScreen.routeName: (context) => SettingsScreen(),
            // TimeReportingScreen.routeName: (context) => TimeReportingScreen(),
            ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen()
          },
        ),
      ),
    );
  }
}

Future<bool> initializeApp() async {
  await Firebase.initializeApp();
  //await FirebaseCoreWeb.registerWith(registrar)
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
      builder: (context, AsyncSnapshot<bool> snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container(
            child: Center(
              child: Text("Det blev något fel"),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Zimple(snapshot.data!);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container(color: primaryColor);
      },
    );
  }
}
