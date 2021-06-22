import 'package:flutter/material.dart';
import '../../../model/person.dart';
import 'package:zimple/utils/constants.dart';

class PersonSelectScreen extends StatefulWidget {
  static const String routeName = 'person_select_screen';
  final List<Person> persons;
  final Function(List<Person>) personCallback;
  final List<Person>? preSelectedPersons;

  PersonSelectScreen(
      {required this.persons,
      required this.personCallback,
      this.preSelectedPersons});
  @override
  _PersonSelectScreenState createState() => _PersonSelectScreenState();
}

class _PersonSelectScreenState extends State<PersonSelectScreen> {
  late Map<Person, bool> selectedPersonsMap;

  @override
  void initState() {
    super.initState();
    selectedPersonsMap = new Map.fromIterable(widget.persons,
        key: (person) => person, value: (person) => false);
    widget.preSelectedPersons?.forEach((person) {
      selectedPersonsMap[person] = true;
    });
  }

  void _performCallback() {
    List<Person> selectedPersons = [];
    widget.persons.forEach((person) {
      if (selectedPersonsMap[person] ?? false) {
        selectedPersons.add(person);
      }
    });
    widget.personCallback(selectedPersons);
  }

  Widget _buildCheckMark(Person person) {
    if (selectedPersonsMap[person] ?? false) {
      return Icon(Icons.check_circle, color: green);
    } else {
      return Icon(Icons.radio_button_off_outlined, color: green);
    }
  }

  void _togglePerson(Person person) {
    setState(() {
      if (selectedPersonsMap[person] == null) return;
      selectedPersonsMap[person] = !selectedPersonsMap[person]!;
    });
  }

  void onPop(BuildContext context) {
    _performCallback();
    Navigator.of(context).pop();
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
            //iconTheme: IconThemeData(color: Colors.white),
            elevation: 0.0,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => onPop(context),
            ),
          ),
          body: ListView.builder(
            padding: EdgeInsets.only(top: 8.0),
            itemBuilder: (context, index) {
              var person = widget.persons[index];
              return _buildPersonRow(person);
            },
            itemCount: widget.persons.length,
          ),
        ));
  }

  _buildPersonCircleAvatar(Person person) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.grey.shade400,
      child: Center(
        child: Text(
          person.name.characters.first.toUpperCase(),
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.0),
        ),
      ),
    );
  }

  _buildPersonRow(Person person) {
    return GestureDetector(
        onTap: () {
          _togglePerson(person);
        },
        child: Container(
          color: Colors.transparent,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SizedBox(
              height: 25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildPersonCircleAvatar(person),
                      SizedBox(width: 12.0),
                      Text(person.name, style: TextStyle(fontSize: 17.0)),
                    ],
                  ),
                  _buildCheckMark(person),
                ],
              ),
            ),
          ),
        ));
  }
}
