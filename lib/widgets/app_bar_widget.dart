import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../utils/constants.dart';

class StandardAppBar extends StatelessWidget {
  final String title;
  const StandardAppBar(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //iconTheme: IconThemeData(color: Colors.white),
      elevation: 0.0,
      brightness: Brightness.dark,
      backgroundColor: primaryColor,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: appBarTitleStyle),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget {
  final Stream<DateTime>? dateStream;
  final String title;
  final bool hasMenu;
  AppBarWidget({this.dateStream, this.title = "", this.hasMenu = false});
  TextStyle _titleStyle() => TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dateStream,
        initialData: DateTime.now(),
        builder: (context, AsyncSnapshot<DateTime> snapshot) {
          return AppBar(
            title: dateStream != null
                ? Text(dateStringMonth(snapshot.data!) + "  |  V." + weekNumber(snapshot.data!).toString(), style: _titleStyle())
                : Text(title, style: _titleStyle()),
            leading: hasMenu
                ? IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      ProviderWidget.of(context).drawerKey.currentState?.openDrawer();
                    },
                  )
                : Container(),
            backgroundColor: primaryColor,
            brightness: Brightness.dark,
            toolbarHeight: 75.0,
            //iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
          );
        });
  }
}
