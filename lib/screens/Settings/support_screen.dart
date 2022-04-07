import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:zimple/screens/Calendar/Onboarding/onboarding_screen.dart';
import 'package:zimple/utils/generic_imports.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: appBarSize, child: StandardAppBar("Support")),
      body: BackgroundWidget(
        child: _body(context),
      ),
    );
  }

  Column _body(BuildContext context) {
    return Column(
      children: [
        //TopHeader(kPadding: kPadding),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 12.0, left: 16),
          child: Text(
            "Vi finns här för att hjälpa dig.\nHör av dig genom att kontakta oss på email eller telefon",
            style: TextStyle(fontSize: 15.0),
          ),
        ),
        SizedBox(height: 12.0),
        ListedView(
          items: [
            ListedItem(
              leadingIcon: Icons.mail,
              text: "Få mailsupport",
              onTap: _onPressedSendMail,
            ),
          ],
        ),
        ListedView(
          items: [
            ListedItem(
              leadingIcon: Icons.info,
              text: "Visa introduktion",
              onTap: () => _onPressedShowIntroduction(context),
            ),
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 24.0),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       Icon(Icons.phone),
        //       SizedBox(width: 16),
        //       Text("0760313335", style: TextStyle(fontSize: 16)),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 10.0),
        // Padding(
        //   padding: const EdgeInsets.only(left: 24.0),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [Icon(Icons.email), SizedBox(width: 16), Text("zebastian@zimple.se", style: TextStyle(fontSize: 16))],
        //   ),
        // )
      ],
    );
  }

  void _onPressedShowIntroduction(BuildContext context) {
    showCupertinoModalPopup(context: context, builder: (context) => OnboardingScreen());
  }

  void _onPressedSendMail() async {
    final Email email = Email(
      body: "",
      subject: "",
      recipients: ["support@zimple.se"],
      attachmentPaths: null,
      isHTML: false,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
      print(platformResponse);
    }
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({
    Key? key,
    required this.kPadding,
  }) : super(key: key);

  final double kPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Support",
                style: TextStyle(color: Colors.white, fontSize: 21.0, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
                child: Text(
                  "Vi finns här för att hjälpa dig.\nHör av dig genom att kontakta oss på email eller telefon",
                  style: TextStyle(fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.w100),
                ),
              )
            ],
          ),
        ));
  }
}
