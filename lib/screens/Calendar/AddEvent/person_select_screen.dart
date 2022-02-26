import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

import '../../../model/person.dart';

class PersonSelectScreen extends StatefulWidget {
  static const String routeName = 'person_select_screen';

  final List<Person> persons;

  final Function(List<Person>) personCallback;

  final List<Person>? preSelectedPersons;

  PersonSelectScreen({required this.persons, required this.personCallback, this.preSelectedPersons});
  @override
  _PersonSelectScreenState createState() => _PersonSelectScreenState();
}

class _PersonSelectScreenState extends State<PersonSelectScreen> {
  late Map<Person, bool> selectedPersonsMap;

  @override
  void initState() {
    super.initState();
    selectedPersonsMap = Map.fromIterable(widget.persons, key: (person) => person, value: (person) => false);
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
    if (isSelected(person))
      return Icon(FeatherIcons.check, color: Colors.white, size: 32);
    else
      return Icon(Icons.circle_outlined, color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), size: 32);
  }

  void _togglePerson(Person person) => setState(
        () {
          if (selectedPersonsMap[person] == null) return;
          selectedPersonsMap[person] = !selectedPersonsMap[person]!;
        },
      );

  void onPop(BuildContext context) {
    _performCallback();
    Navigator.of(context).pop();
  }

  bool isSelected(Person person) => selectedPersonsMap[person] ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        "Välj personer",
        trailing: TextButton(
          child: Text("Spara", style: TextStyle(color: Colors.white, fontSize: 17)),
          onPressed: () => onPop(context),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          var person = widget.persons[index];
          return _buildPersonRow(person);
        },
        itemCount: widget.persons.length,
      ),
    );
  }

  _buildPersonCircleAvatar(Person person) {
    return ProfilePictureIcon(
      person: person,
      size: Size(40, 40),
      fontSize: 16,
    );
  }

  _buildPersonRow(Person person) {
    return GestureDetector(
        onTap: () {
          _togglePerson(person);
          _performCallback();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          color: isSelected(person) ? ThemeNotifier.of(context).green : Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildPersonCircleAvatar(person),
                      SizedBox(width: 12.0),
                      Text(person.name,
                          style: TextStyle(
                            fontSize: 17.0,
                            color: isSelected(person) ? Colors.white : ThemeNotifier.of(context).textColor,
                            fontWeight: isSelected(person) ? FontWeight.bold : FontWeight.normal,
                          )),
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

class PersonSelectRow extends StatelessWidget {
  final VoidCallback onTapPerson;

  final bool isSelected;

  final Person person;

  final Color? backgroundColor;

  final Color? textColor;

  const PersonSelectRow({
    Key? key,
    required this.onTapPerson,
    required this.isSelected,
    required this.person,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPersonRow(context, person);
  }

  _buildPersonCircleAvatar(Person person) {
    return ProfilePictureIcon(
      person: person,
      size: Size(40, 40),
      fontSize: 16,
    );
  }

  _buildPersonRow(BuildContext context, Person person) {
    return GestureDetector(
        onTap: onTapPerson,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          color: isSelected ? ThemeNotifier.of(context).green : backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildPersonCircleAvatar(person),
                      SizedBox(width: 12.0),
                      Text(person.name,
                          style: TextStyle(
                            fontSize: 17.0,
                            color: isSelected ? Colors.white : (textColor ?? ThemeNotifier.of(context).textColor),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          )),
                    ],
                  ),
                  _buildCheckMark(context, person),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildCheckMark(BuildContext context, Person person) {
    if (isSelected)
      return Icon(FeatherIcons.check, color: Colors.white, size: 32);
    else
      return Icon(Icons.circle_outlined, color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), size: 32);
  }
}
