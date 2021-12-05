import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isDarkMode;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: StandardAppBar("Inställningar"),
      ),
      body: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dark mode", style: TextStyle(fontSize: 16)),
                    CupertinoSwitch(
                        value: theme.isDarkMode(),
                        onChanged: (val) {
                          if (theme.isDarkMode())
                            theme.setLightMode();
                          else
                            theme.setDarkMode();
                        }),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
