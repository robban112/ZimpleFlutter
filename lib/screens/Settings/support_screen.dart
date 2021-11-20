import 'package:flutter/material.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import '../../utils/constants.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(60), child: StandardAppBar("Support")),
        body: Column(
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
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 16),
                  Text("07012345678"),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Icon(Icons.email), SizedBox(width: 16), Text("zebastian@zimple.se")],
              ),
            )
          ],
        ));
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
