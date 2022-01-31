import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:zimple/screens/Calendar/Notes/notes_screen.dart';
import '../utils/date_utils.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../utils/constants.dart';

class StandardAppBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const StandardAppBar(
    this.title, {
    Key? key,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
      ),
      elevation: 0.0,
      brightness: Brightness.dark,
      backgroundColor: primaryColor,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: appBarTitleStyle),
      ),
      leading: NavBarBack(),
      actions: [trailing ?? Container()],
    );
  }
}

class NavBarBack extends StatelessWidget {
  final VoidCallback? onPressed;

  const NavBarBack({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed != null ? () => onPressed!() : () => Navigator.of(context).pop(),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: SvgPicture.asset(
                'images/arrow_back.svg',
                color: Colors.white,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget {
  final Stream<DateTime>? dateStream;

  final String title;

  final bool hasMenu;

  AppBarWidget({
    this.dateStream,
    this.title = "",
    this.hasMenu = false,
  });

  TextStyle _titleStyle() => TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w900, letterSpacing: 0.1);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dateStream,
        initialData: DateTime.now(),
        builder: (context, AsyncSnapshot<DateTime> snapshot) {
          return AppBar(
            title: dateStream != null ? dateWidget(snapshot) : Text(title, style: _titleStyle()),
            leading: hasMenu
                ? IconButton(
                    icon: SizedBox(height: 24, width: 24, child: SvgPicture.asset('images/menu.svg', color: Colors.white)),
                    onPressed: () {
                      ProviderWidget.of(context).drawerKey.currentState?.openDrawer();
                    },
                  )
                : Container(),
            actions: [
              CupertinoButton(
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => NotesScreen(
                      firebaseNotesManager: ManagerProvider.of(context).firebaseNotesManager,
                    ),
                  ),
                ),
                child: Icon(
                  FeatherIcons.fileText,
                  color: Colors.white,
                ),
              ),
            ],
            backgroundColor: primaryColor,
            brightness: Brightness.dark,
            toolbarHeight: 75.0,
            //iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
          );
        });
  }

  Widget dateWidget(AsyncSnapshot<DateTime> snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(dateStringMonth(snapshot.data!) + "  |  V." + weekNumber(snapshot.data!).toString(), style: _titleStyle()),
      ],
    );
  }
}
