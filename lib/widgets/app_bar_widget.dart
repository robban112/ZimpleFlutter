import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../utils/constants.dart';

class AppBarWidget extends StatelessWidget {
  final Stream<DateTime> dateStream;
  final String title;
  AppBarWidget({this.dateStream, this.title = ""});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dateStream,
        initialData: DateTime.now(),
        builder: (context, AsyncSnapshot<DateTime> snapshot) {
          return AppBar(
            title: dateStream != null
                ? Text(
                    dateStringMonth(snapshot.data) +
                        "  |  V." +
                        weekNumber(snapshot.data).toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold))
                : Text(title),
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                ProviderWidget.of(context).drawerKey.currentState.openDrawer();
              },
            ),
            backgroundColor: primaryColor,
            toolbarHeight: 75.0,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
          );
        });
  }
}
