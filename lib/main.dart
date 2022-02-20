import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:zimple/screens/Login/Signup/sign_up_screen.dart';
import 'package:zimple/screens/Login/first_login_screen.dart';
import 'package:zimple/screens/Login/forgot_password_screen.dart';
import 'package:zimple/screens/Splash/splash_screen.dart';
import 'package:zimple/utils/service/analytics_service.dart';
import 'package:zimple/utils/service/user_service.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';

import 'screens/Login/login_screen.dart';
import 'screens/tab_bar_widget.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => new ThemeNotifier(),
        child: App(),
      ),
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _hasFinishedSplash = false;

  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Initialize FlutterFire
      stream: firebaseUserStream(),
      builder: (context, firebaseUser) {
        // Once complete, show your application
        if (_hasFinishedSplash) {
          return Zimple(firebaseUser.data);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return SplashScreen(finishedSplash: () => setState(() => _hasFinishedSplash = true));
      },
    );
  }
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

Stream<User?> firebaseUserStream() {
  Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();
  userStream.listen((event) {
    print("New User: $event");
  });
  return userStream;
}

class Zimple extends StatefulWidget {
  final User? user;

  Zimple(this.user);

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

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    askPermissionForPush();
    initDynamicLinks();
    _handleIncomingLinks();
    _handleInitialUri();
    _initializeFlutterFire();
    super.initState();
  }

  Future<void> initDynamicLinks() async {
    print("Setting up Firebase Dynamic Link");
    Stream<PendingDynamicLinkData> stream = FirebaseDynamicLinks.instance.onLink;
    stream.listen((event) {
      final Uri? deepLink = event.link;
      print("Got deep link: $deepLink");
    });
  }

  void _onGotUri(Uri uri) {
    print('got uri: $uri');
    if (widget.user != null)
      print("user is authenticated");
    else {
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
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
    );

    FirebaseMessaging.onBackgroundMessage(_throwGetMessage);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ManagerProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsService()),
        ChangeNotifierProvider(create: (_) => UserService(widget.user)),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) => MaterialApp(
          navigatorKey: _navigatorKey,
          localizationsDelegates: [GlobalCupertinoLocalizations.delegate, GlobalMaterialLocalizations.delegate],
          supportedLocales: [const Locale('sv', 'SV')],
          locale: Locale.fromSubtags(languageCode: 'sv'),
          debugShowCheckedModeBanner: false,
          theme: theme.getTheme(),
          navigatorObservers: [observer],
          onGenerateRoute: (RouteSettings routeSettings) {
            print("generated route: ${routeSettings.name}");
          },
          initialRoute: widget.user != null ? TabBarWidget.routeName : LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            TabBarWidget.routeName: (context) => TabBarWidget(),
            FirstLoginScreen.routeName: (context) => FirstLoginScreen(email: '', token: ''),
            // SettingsScreen.routeName: (context) => SettingsScreen(),
            // TimeReportingScreen.routeName: (context) => TimeReportingScreen(),
            ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
            SignUpScreen.routeName: (context) => SignUpScreen(),
          },
        ),
      ),
    );
  }
}
