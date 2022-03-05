import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zimple/screens/Calendar/Notes/notes_screen.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';

import '../utils/constants.dart';
import '../utils/date_utils.dart';
import 'button/nav_bar_back.dart';

PreferredSize appBar(String title, {Size size = appBarSize, bool withBackButton = true, Widget? trailing}) => PreferredSize(
      preferredSize: appBarSize,
      child: StandardAppBar(
        title,
        withBackButton: withBackButton,
        trailing: trailing,
      ),
    );

class StandardAppBar extends StatelessWidget {
  final String title;

  final Widget? trailing;

  final VoidCallback? onPressedBack;

  final bool withBackButton;

  const StandardAppBar(
    this.title, {
    Key? key,
    this.trailing,
    this.onPressedBack,
    this.withBackButton = true,
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
      backgroundColor: ThemeNotifier.darkThemePrimaryBg,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: appBarTitleStyle),
      ),
      flexibleSpace: AppBarBackground(),
      leading: withBackButton ? NavBarBack(onPressed: onPressedBack) : null,
      actions: [trailing ?? Container()],
    );
  }
}

class AppBarBackground extends StatelessWidget {
  const AppBarBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    20,
                    (rowIndex) => Container(
                      height: 2,
                      width: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25 - 0.04 * index),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}

class AppBarWidget extends StatelessWidget {
  final Stream<DateTime>? dateStream;

  final String title;

  final bool hasMenu;

  final VoidCallback? onTapFilter;

  AppBarWidget({
    this.dateStream,
    this.title = "",
    this.hasMenu = false,
    this.onTapFilter,
  });

  TextStyle _titleStyle() => TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.w900, letterSpacing: 0.1);

  @override
  Widget build(BuildContext context) {
    bool shouldShowFilter = ManagerProvider.of(context).user.isAdmin;
    if (!ManagerProvider.of(context).companySettings.isPrivateEvents) {
      shouldShowFilter = true;
    }

    return StreamBuilder(
        stream: dateStream,
        initialData: DateTime.now(),
        builder: (context, AsyncSnapshot<DateTime> snapshot) {
          return AppBar(
            title: dateStream != null ? dateWidget(snapshot) : Text(title, style: _titleStyle()),
            leading: hasMenu ? _menuButton(context) : Container(),
            actions: [
              if (shouldShowFilter) _buildFilterButton(),
              _notesButton(context),
            ],
            flexibleSpace: AppBarBackground(),
            backgroundColor: ThemeNotifier.darkThemePrimaryBg,
            brightness: Brightness.dark,
            toolbarHeight: 75.0,
            //iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
          );
        });
  }

  Container _buildFilterButton() {
    return Container(
      height: 50,
      width: 40,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTapFilter,
        child: Icon(
          FeatherIcons.filter,
          color: Colors.white,
        ),
      ),
    );
  }

  IconButton _menuButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: SizedBox(height: 24, width: 24, child: SvgPicture.asset('images/menu.svg', color: Colors.white)),
      onPressed: () {
        ProviderWidget.of(context).drawerKey.currentState?.openDrawer();
      },
    );
  }

  Container _notesButton(BuildContext context) {
    return Container(
      height: 50,
      width: 40,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
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
    );
  }

  Widget dateWidget(AsyncSnapshot<DateTime> snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(dateStringMonth(snapshot.data!) + "  |  V." + weekNumber(snapshot.data!).toString(), style: _titleStyle()),
      ],
    );
  }
}
