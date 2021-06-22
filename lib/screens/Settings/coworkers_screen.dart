import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';

class CoworkersScreen extends StatefulWidget {
  @override
  _CoworkersScreenState createState() => _CoworkersScreenState();
}

class _CoworkersScreenState extends State<CoworkersScreen> {
  late PersonManager personManager;

  @override
  void initState() {
    personManager =
        Provider.of<ManagerProvider>(context, listen: false).personManager;
    super.initState();
  }

  Widget _buildProfile(Person person) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade400,
      child: Text(person.name.characters.first.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medarbetare"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        child: DataTable(
          dividerThickness: 0,
          columnSpacing: 25,
          rows: personManager.persons.map((person) {
            print(person.phonenumber);
            return DataRow(cells: [
              DataCell(_buildProfile(person)),
              DataCell(Text(person.name)),
              DataCell(Text(person.phonenumber ?? "")),
              DataCell(Text(person.email ?? "")),
            ]);
          }).toList(),
          columns: [
            DataColumn(label: Text('')),
            DataColumn(
                label: Text('Namn', style: TextStyle(color: Colors.grey))),
            DataColumn(
                label: Text('Telefon', style: TextStyle(color: Colors.grey))),
            DataColumn(
                label: Text('Email', style: TextStyle(color: Colors.grey)))
          ],
        ),
      ),
    );
  }
}
