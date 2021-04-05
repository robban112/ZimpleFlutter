import 'package:flutter/material.dart';
import '../../model/person.dart';

class PersonSelectScreen extends StatefulWidget {
  static const String routeName = 'person_select_screen';
  List<Person> persons;
  Function(List<Person>) personCallback;
  List<Person> preSelectedPersons;

  PersonSelectScreen(
      {@required this.persons,
      @required this.personCallback,
      this.preSelectedPersons});
  @override
  _PersonSelectScreenState createState() => _PersonSelectScreenState();
}

class _PersonSelectScreenState extends State<PersonSelectScreen> {
  Map<Person, bool> selectedPersonsMap;

  @override
  void initState() {
    super.initState();
    selectedPersonsMap = new Map.fromIterable(widget.persons,
        key: (person) => person, value: (person) => false);
    widget.preSelectedPersons.forEach((person) {
      selectedPersonsMap[person] = true;
    });
  }

  void _performCallback() {
    List<Person> selectedPersons = [];
    widget.persons.forEach((person) {
      if (selectedPersonsMap[person]) {
        selectedPersons.add(person);
      }
    });
    widget.personCallback(selectedPersons);
  }

  Widget _buildDivider([double thickness]) {
    thickness ??= 0.5;
    return Divider(height: 20, thickness: thickness, color: Colors.grey);
  }

  Widget _buildCheckMark(Person person) {
    if (selectedPersonsMap[person]) {
      return Icon(Icons.check);
    } else {
      return null;
    }
  }

  void _togglePerson(Person person) {
    setState(() {
      selectedPersonsMap[person] = !selectedPersonsMap[person];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _performCallback();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0.0,
              backgroundColor: Colors.blueGrey),
          body: ListView.builder(
            itemBuilder: (context, index) {
              var person = widget.persons[index];
              return ListTile(
                title: Text(person.name, style: TextStyle(fontSize: 17.0)),
                onTap: () {
                  _togglePerson(person);
                },
                trailing: _buildCheckMark(person),
              );
            },
            itemCount: widget.persons.length,
          ),
        ));
  }
}
