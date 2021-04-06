import 'package:flutter/material.dart';
import 'package:zimple/widgets/app_bar_widget.dart';

class TimeReportingScreen extends StatelessWidget {
  static const routeName = "time_reporting_screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Center(child: Text("Tidrapportering")),
      ),
      body: Center(child: Text("Tidrapportering")),
    );
  }
}
