import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/Signup/enter_calendarname_step.dart';
import 'package:zimple/screens/Login/Signup/enter_email_step.dart';
import 'package:zimple/screens/Login/Signup/enter_password_step.dart';
import 'package:zimple/screens/Login/Signup/enter_phonenumber_step.dart';
import 'package:zimple/screens/Login/Signup/sign_up_progress_screen.dart';
import 'package:zimple/screens/Login/Signup/step_indicator.dart';
import 'package:zimple/screens/Login/components/abstract_wave_animation.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = "sign_up_screen";

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const numSteps = 4;

  int currentPage = 0;

  final PageController pageController = PageController();

  String? email;

  String? calendarName;

  String? phonenumber;

  String? password;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode phonenumberFocusNode = FocusNode();
  FocusNode calendarNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: appBarSize,
        child: StandardAppBar(
          "Registrera konto",
          onPressedBack: onTapBack,
        ),
      ),
      backgroundColor: Colors.black,
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Stack(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ZimpleDotBackground(
              shouldAnimate: true,
              overrideColor: ThemeNotifier.of(context).textColor,
            ),
            Align(alignment: Alignment.topCenter, child: StepIndicator(numSteps: numSteps, currentStep: currentPage)),
            //_buildEnteredInfo(),
            Center(
              child: PageView(
                controller: pageController,
                scrollBehavior: ScrollBehavior(),
                physics: NeverScrollableScrollPhysics(),
                children: [
                  EnterEmailStep(
                    onSubmit: onSubmitEmail,
                    email: email,
                    focusNode: emailFocusNode,
                  ),
                  EnterCalendarNameStep(
                    onSubmit: onSubmitCalendarName,
                    calendarName: calendarName,
                    focusNode: calendarNameFocusNode,
                  ),
                  EnterPhonenumberStep(
                    onSubmit: onSubmitPhonenumber,
                    phonenumber: phonenumber,
                    focusNode: phonenumberFocusNode,
                  ),
                  EnterPasswordStep(
                    onSubmit: onSubmitPassword,
                    password: password,
                    focusNode: passwordFocusNode,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnteredInfo() {
    TextStyle style = TextStyle(
      color: Colors.white,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (email != null) _enteredInfo('Email: ', email!),
        ],
      ),
    );
  }

  RichText _enteredInfo(String title, String text) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  void onSubmitPassword(String value) {
    setState(() {
      this.password = value;
    });
    print("Done with registration!");
    print(email);
    print(password);
    print(calendarName);
    print(phonenumber);
    if (email != null && password != null && calendarName != null && phonenumber != null) {
      print("Done with registration!");
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (context) => SignUpProgressScreen(
            email: email!,
            password: password!,
            calendarName: calendarName!,
            phonenumber: phonenumber!,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void onSubmitPhonenumber(String value) {
    setState(() {
      this.phonenumber = value;
    });
    nextPage();
  }

  void onSubmitCalendarName(String name) {
    setState(() {
      this.calendarName = name;
    });
    nextPage();
  }

  void onSubmitEmail(String email) {
    setState(() {
      this.email = email;
    });
    nextPage();
  }

  void onTapBack() {
    if (currentPage > 0)
      previousPage();
    else
      Navigator.of(context).pop();
  }

  void previousPage() {
    pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    setState(() {
      this.currentPage -= 1;
    });
    focusNodeFor(currentPage)?.requestFocus();
  }

  void nextPage() {
    if (currentPage < numSteps) {
      pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      setState(() {
        this.currentPage += 1;
      });
      focusNodeFor(currentPage)?.requestFocus();
    }
  }

  FocusNode? focusNodeFor(int i) {
    switch (i) {
      case 0:
        return emailFocusNode;
      case 1:
        return calendarNameFocusNode;
      case 2:
        return phonenumberFocusNode;
      case 3:
        return passwordFocusNode;
    }
  }
}
