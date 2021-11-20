import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/screens/Settings/Coworkers/add_coworker_screen.dart';
import 'package:zimple/screens/Settings/Coworkers/coworker_details_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:styled_widget/styled_widget.dart';

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
    return CircleAvatar(
      radius: 15,
      backgroundColor: person.color,
      child: Text(person.name.characters.first.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    PersonManager personManager = context.watch<ManagerProvider>().personManager;
    UserParameters user = context.read<ManagerProvider>().user;
    return Scaffold(
      floatingActionButton: user.isAdmin
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _onPressedAddUser,
            )
          : Container(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
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
    HapticFeedback.mediumImpact();
    Navigator.push(context, CupertinoPageRoute(builder: (_) => AddCoworkerScreen()));
  }
}
