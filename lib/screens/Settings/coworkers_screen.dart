import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/screens/Settings/Coworkers/add_coworker_screen.dart';
import 'package:zimple/screens/Settings/Coworkers/coworker_details_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/floating_add_button.dart';
import 'package:zimple/widgets/widgets.dart';

class CoworkersScreen extends StatefulWidget {
  @override
  _CoworkersScreenState createState() => _CoworkersScreenState();
}

class _CoworkersScreenState extends State<CoworkersScreen> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildProfile(Person person) {
    return ProfilePictureIcon(
      person: person,
      size: Size(40, 40),
      fontSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    PersonManager personManager = context.watch<ManagerProvider>().personManager;
    UserParameters user = context.read<ManagerProvider>().user;
    return Scaffold(
      floatingActionButton: user.isAdmin ? FloatingAddButton(onPressed: _onPressedAddUser) : Container(),
      appBar: PreferredSize(
        preferredSize: appBarSize,
        child: StandardAppBar("Medarbetare"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        child: DataTable(
          showCheckboxColumn: false,
          dividerThickness: 0.1,
          columnSpacing: 25,
          rows: personManager.persons.map((person) {
            return DataRow(onSelectChanged: (_) => pushNewScreen(context, screen: CoworkerDetailsScreen(person: person)), cells: [
              DataCell(_buildProfile(person)),
              DataCell(Text(person.name)),
              DataCell(Text(person.phonenumber ?? "")),
              DataCell(Text(person.email ?? "")),
            ]);
          }).toList(),
          columns: [
            DataColumn(label: Text('')),
            DataColumn(label: Text('Namn', style: TextStyle(color: Colors.grey))),
            DataColumn(label: Text('Telefon', style: TextStyle(color: Colors.grey))),
            DataColumn(label: Text('Email', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  void _onPressedAddUser() {
    HapticFeedback.lightImpact();
    Navigator.push(context, CupertinoPageRoute(builder: (_) => AddCoworkerScreen()));
  }
}
