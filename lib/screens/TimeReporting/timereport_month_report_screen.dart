import 'package:flutter/material.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/utils/constants.dart';

class TimereportMonthReportScreen extends StatefulWidget {
  const TimereportMonthReportScreen({required this.timereports, required this.month, Key? key}) : super(key: key);

  final List<TimeReport> timereports;
  final String month;

  @override
  _TimereportMonthReportScreenState createState() => _TimereportMonthReportScreenState();
}

class _TimereportMonthReportScreenState extends State<TimereportMonthReportScreen> {
  String _calculateTotalTime() {
    int time = 0;
    for (TimeReport timereport in widget.timereports) {
      time += timereport.totalTime;
    }
    double _time = time / 60;
    return _time.toStringAsFixed(1);
  }

  int totalminutes() {
    return widget.timereports.fold<int>(0, (prev, timereport) => prev + timereport.totalTime);
  }

  int totalBreak() {
    return widget.timereports.fold<int>(0, (prev, timereport) => prev + timereport.breakTime);
  }

  Padding _buildRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
          Text(right, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: primaryColor,
            title: Text("Månadsrapport ${widget.month}", style: TextStyle(color: Colors.white))),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Totaltid: ", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
                    Text(_calculateTotalTime(), style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              _buildRow("Totaltid i minuter: ", totalminutes().toString()),
              _buildRow("Rast i minuter: ", totalBreak().toString()),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Antal rapporter: ", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
                    Text(widget.timereports.length.toString(), style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
