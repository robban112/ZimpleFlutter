import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:zimple/screens/Login/first_login_screen.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'screens/Login/login_screen.dart';
import 'screens/tab_bar_controller.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

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

Future<bool> isUserLoggedIn() async {
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
  StreamSubscription? _sub;
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;
  bool _initialUriIsHandled = false;

  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    askPermissionForPush();
    initDynamicLinks();
    _handleIncomingLinks();
    _handleInitialUri();
    super.initState();
  }

  Future<void> initDynamicLinks() async {
    print("Setting up Firebase Dynamic Link");
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      print("Got deep link: $deepLink");
    });
  }

  void _onGotUri(Uri uri) {
    print('got uri: $uri');
    if (!widget.isLoggedIn) {
      print("user is not logged in");
      List<String> pathSegments = uri.pathSegments;
      print("path segments: $pathSegments");
      Map<String, String> queryParameters = uri.queryParameters;
      if (pathSegments[0] == 'first-sign-in') {
        String? token = queryParameters['token'];
        String? email = queryParameters['email'];
        if (token != null && email != null) {
          print("Log in user with $email + $token");
          Future.delayed(Duration(seconds: 1), () {
            print("Pushing new route");
            _navigatorKey.currentState
                ?.push(MaterialPageRoute(builder: (context) => FirstLoginScreen(email: email, token: token)));
            //Navigator.push(context, MaterialPageRoute(builder: (context) => FirstLoginScreen(email: email, token: token)));
          });
        }
      }
    }
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      if (uri == null) return;

      _onGotUri(uri);
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      // setState(() {
      //   //_latestUri = null;
      //   if (err is FormatException) {
      //     //_err = err;
      //   } else {
      //     //_err = null;
      //   }
      // });
    });
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      //_showSnackBar('_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri');
          _onGotUri(uri);
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        setState(() => _err = err);
      }
    }
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
          navigatorKey: _navigatorKey,
          localizationsDelegates: [GlobalCupertinoLocalizations.delegate, GlobalMaterialLocalizations.delegate],
          supportedLocales: [const Locale('sv', 'SV')],
          locale: Locale.fromSubtags(languageCode: 'sv'),
          debugShowCheckedModeBanner: false,
          theme: theme.getTheme(),
          onGenerateRoute: (RouteSettings routeSettings) {
            print("generated route: ${routeSettings.name}");
          },
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
            FirstLoginScreen.routeName: (context) => FirstLoginScreen(email: '', token: ''),
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
