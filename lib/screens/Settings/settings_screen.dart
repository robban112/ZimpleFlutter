import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view/listed_switch.dart';
import 'package:zimple/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

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
        preferredSize: appBarSize,
        child: StandardAppBar("Inställningar"),
      ),
      body: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                if (ManagerProvider.of(context).user.isAdmin) _buildSetPrivateWorkordersRow(context),
                const SizedBox(height: 12),
                ListedView(
                  rowInset: EdgeInsets.symmetric(vertical: 12),
                  items: [
                    ListedSwitch(
                      text: 'Dark Mode',
                      initialValue: theme.isDarkMode(),
                      leadingIcon: Icons.privacy_tip,
                      onChanged: (value) => theme.isDarkMode() ? theme.setLightMode() : theme.setDarkMode(),
                    ),
                    ListedItem(
                        trailingIcon: Icons.chevron_right,
                        leadingIcon: Icons.logout,
                        text: "Logga ut",
                        onTap: () {
                          widget.onLogout();
                        }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Row _buildSetPrivateWorkordersRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sätt privata arbetsordrar",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                "Ifall du väljer denna kommer dina medarbetare bara se sitt egna schema",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        CupertinoSwitch(
          value: context.watch<ManagerProvider>().companySettings.isPrivateEvents,
          onChanged: (val) {
            CompanySettings companySettings = ManagerProvider.of(context).companySettings;
            CompanySettings newCompanySettings = companySettings.copyWith(isPrivateEvents: val);
            ManagerProvider.of(context).firebaseCompanyManager.updateCompanySettings(companySettings: newCompanySettings);
          },
        ),
      ],
    );
  }

  Widget _buildRowItem({required String title, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
        child,
      ],
    );
  }
}
