import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/screens/Calendar/AddEvent/person_select_screen.dart';
import 'package:zimple/utils/theme_manager.dart';

class FilterPersonsPage extends StatefulWidget {
  final Map<Person, bool> preSelectedPersons;

  final Function(List<Person> selectedPersons) selected;

  FilterPersonsPage({
    Key? key,
    required this.preSelectedPersons,
    required this.selected,
  }) : super(key: key);

  @override
  State<FilterPersonsPage> createState() => _FilterPersonsPageState();
}

class _FilterPersonsPageState extends State<FilterPersonsPage> {
  Map<Person, bool> selectedPersons = {};

  @override
  void initState() {
    selectedPersons = widget.preSelectedPersons;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Person> persons = selectedPersons.keys.toList();
    persons.sort((p1, p2) => p1.name.compareTo(p2.name));
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Scaffold(
        backgroundColor: Color(0xff0F0E0E).withOpacity(ThemeNotifier.of(context).isDarkMode() ? 0 : 0.6),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                _markAllButton(context),
                _buildCloseButton(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 70.0),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: ((context, index) {
                          Person person = persons[index];
                          return _buildPersonSelect(person);
                        }),
                        itemCount: selectedPersons.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Align _markAllButton(BuildContext context) {
    bool allMarked = selectedPersons.values.every((e) => e);
    return Align(
      alignment: Alignment.topRight,
      child: CupertinoButton(
        onPressed: () => _onTapMarkAll(allMarked),
        padding: EdgeInsets.zero,
        child: Container(
          height: 55,
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(!allMarked ? "Markera alla" : "Avmarkera alla",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  void _onTapMarkAll(bool allMarked) {
    setState(() {
      this.selectedPersons.keys.forEach((element) {
        selectedPersons[element] = !allMarked;
      });
    });
  }

  void onTapClose() {
    widget.selected(
      selectedPersons.keys.where((element) => selectedPersons[element]!).toList(),
    );
    Navigator.of(context).pop();
  }

  Align _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTapClose,
        child: Container(
          height: 55,
          width: 250,
          decoration: BoxDecoration(color: ThemeNotifier.of(context).red, borderRadius: BorderRadius.circular(24)),
          child: Center(child: Text("STÄNG", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18))),
        ),
      ),
    );
  }

  Widget _buildPersonSelect(Person person) {
    bool isSelected = selectedPersons[person]!;
    return PersonSelectRow(
      onTapPerson: () {
        setState(() {
          selectedPersons[person] = !isSelected;
        });
      },
      isSelected: isSelected,
      person: person,
      textColor: Colors.white,
      backgroundColor: Colors.transparent,
    );
  }
}

enum ZButtonType {
  red,
  green,
  opaque,
}

class ZButton extends StatelessWidget {
  final VoidCallback onTap;
  final ZButtonType type;
  final String text;
  final double width;
  const ZButton({
    Key? key,
    required this.text,
    this.type = ZButtonType.green,
    required this.onTap,
    this.width = 160,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        child: Container(
          height: 60,
          width: width,
          decoration: BoxDecoration(
            color: color(context),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ),
    );
  }

  Color color(BuildContext context) {
    switch (type) {
      case ZButtonType.red:
        return ThemeNotifier.of(context).red;
      case ZButtonType.green:
        return ThemeNotifier.of(context).green;
      case ZButtonType.opaque:
        return Colors.white.withOpacity(0.1);
    }
  }
}
