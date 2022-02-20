import 'package:flutter/material.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/widgets/widgets.dart';

class PersonCircleAvatar extends StatelessWidget {
  final Person person;
  final double radius;
  final double fontSize;
  final double opacity;
  final bool withBorder;

  PersonCircleAvatar({required this.person, this.radius = 15, this.fontSize = 11.0, this.opacity = 1, this.withBorder = false});
  @override
  Widget build(BuildContext context) {
    return ProfilePictureIcon(person: person);
  }
}

class ListPersonCircleAvatar extends StatelessWidget {
  final List<Person> persons;

  final double spacing;

  final double radius;

  final double fontSize;

  final double widthMultiplier;

  final WrapAlignment alignment;

  const ListPersonCircleAvatar({
    required this.persons,
    this.spacing = 5.0,
    this.radius = 10,
    this.fontSize = 11.0,
    this.widthMultiplier = 0.5,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthMultiplier,
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        direction: Axis.horizontal,
        alignment: alignment,
        children: List.generate(
          persons.length,
          (index) {
            var person = persons[index];
            return ProfilePictureIcon(key: ValueKey(person.id), person: person);
          },
        ),
      ),
    );
  }
}
