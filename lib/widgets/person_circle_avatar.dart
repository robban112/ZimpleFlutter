import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/utils/theme_manager.dart';

class PersonCircleAvatar extends StatelessWidget {
  final Person person;
  final double radius;
  final double fontSize;
  final double opacity;
  final bool withBorder;

  PersonCircleAvatar({required this.person, this.radius = 15, this.fontSize = 11.0, this.opacity = 1, this.withBorder = false});
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context, listen: true).isDarkMode();
    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey.shade800.withOpacity(opacity) : Colors.grey.shade400.withOpacity(opacity),
        border: withBorder ? Border.all(color: Theme.of(context).dividerColor) : null,
      ),
      child: Center(
        child: Text(
          person.name.characters.first.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
      ),
    );
  }
}

class ListPersonCircleAvatar extends StatelessWidget {
  final List<Person> persons;
  final double spacing;
  final double radius;
  final double fontSize;
  const ListPersonCircleAvatar({
    required this.persons,
    this.spacing = 5.0,
    this.radius = 10,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        direction: Axis.horizontal,
        children: List.generate(persons.length, (index) {
          var person = persons[index];
          return PersonCircleAvatar(person: person, radius: this.radius, fontSize: this.fontSize);
          return Row(
            children: [PersonCircleAvatar(person: person, radius: this.radius, fontSize: this.fontSize)],
          );
        }));
  }
}
