import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zimple/network/firebase_signup_manager.dart';
import 'package:zimple/screens/tab_bar_widget.dart';

class SignUpProgressScreen extends StatefulWidget {
  final String email;

  final String password;

  final String calendarName;

  final String phonenumber;

  const SignUpProgressScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.calendarName,
    required this.phonenumber,
  }) : super(key: key);

  @override
  _SignUpProgressScreenState createState() => _SignUpProgressScreenState();
}

class _SignUpProgressScreenState extends State<SignUpProgressScreen> {
  bool hasError = false;

  String errorMessage = "Okänt fel inträffade";

  @override
  void initState() {
    createCalendar();
    super.initState();
  }

  /*
  ! GÖR 
  TODO: DO THIS
  * * HEJ
  ? WTF
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasError ? errorMessage : "Skapar ditt konto",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: hasError ? Colors.red : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(backgroundColor: Colors.white, value: null),
          ],
        ),
      ),
    );
  }

  void completeSetup() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: widget.email.trim(), password: widget.password.trim());
      Navigator.pushNamedAndRemoveUntil(context, TabBarWidget.routeName, (route) => false);
    } catch (error) {
      print("Couldn't log in");
      onError();
    }
  }

  Future<void> createCalendar() async {
    try {
      UserCredential credential = await createUser(widget.email, widget.password);
      String companyId = await createCompany(credential);
      await addUserToUserDatabase(userId: credential.user!.uid, companyId: companyId);
      await FirebaseSignupManager().trackNewUser(
        userId: credential.user!.uid,
        userEmail: widget.email,
        userPhone: widget.phonenumber,
        calendarId: companyId,
      );
      completeSetup();
    } catch (error) {
      print("Couldn't Create calendar");
      onError();
    }
  }

  Future<void> addUserToUserDatabase({required String userId, required String companyId}) {
    return FirebaseSignupManager().addUserToUserDatabase(userId: userId, email: widget.email, companyId: companyId);
  }

  Future<String> createCompany(UserCredential credentials) async {
    try {
      String? userId = credentials.user?.uid;
      if (userId == null) {
        throw Error();
      }
      String companyId = await FirebaseSignupManager().createCompany(
        calendarName: widget.calendarName,
        userId: userId,
        userEmail: widget.email,
        userPhone: widget.phonenumber,
      );
      return companyId;
    } catch (error) {
      print("Couldn't create company");
      onError();
      throw error;
    }
  }

  Future<UserCredential> createUser(String email, String password) async {
    try {
      UserCredential credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await credentials.user?.sendEmailVerification();
      return credentials;
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? errorMessage;
      });
      onError();
      print("Couldn't create user: FirebaseAuthException");
      throw e;
    } catch (error) {
      print("Couldn't create user");
      onError();
      throw error;
    }
  }

  Future<void> onError() {
    setState(() {
      hasError = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
    return Future.value();
  }
}
