import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/screens/TimeReporting/Vacation/abscence_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class ApproveEventItem extends StatelessWidget {
  final Event event;

  const ApproveEventItem({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (event.eventType != EventType.event) return Container();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: ThemeNotifier.of(context).isDarkMode() ? null : standardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTitleDescriptionText(context),
            const SizedBox(width: 6),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            ActionButton(color: Colors.yellow.shade700, icon: Icon(FontAwesome.pencil, color: Colors.white), onPressed: () {}),
            const SizedBox(height: 6),
            Text("Ändra", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
          ],
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            ActionButton(color: Colors.green, icon: Icon(Icons.check, color: Colors.white), onPressed: () {}),
            const SizedBox(height: 6),
            Text("Godkänn", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleDescriptionText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        buildTimeRow(),
        const SizedBox(height: 6),
        _buildProfilePictures(context),
      ],
    );
  }

  Widget _buildProfilePictures(BuildContext context) {
    if (event.persons == null) return Container();
    List<Person> persons = event.persons!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 40,
          child: Stack(
            alignment: Alignment.topLeft,
            children: List.generate(
              persons.take(3).length,
              (index) => Padding(
                padding: EdgeInsets.only(left: index * 12),
                child: PersonCircleAvatar(
                  radius: 10,
                  person: persons[index],
                  opacity: opacityForIndex(index),
                  //withBorder: true,
                  fontSize: 9,
                ),
              ),
            ).reversed.toList(),
          ),
        ),
        if (persons.length > 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 17.0),
            child: Text("+${persons.length - 3}",
                style: TextStyle(fontSize: 12, color: ThemeNotifier.of(context).textColor.withOpacity(0.4))),
          )
        else
          const SizedBox(width: 10)
      ],
    );
  }

  Widget buildTimeRow() {
    if (event.eventType == EventType.vacation) {
      return Container();
    }
    return Row(
      children: [
        Text(dateToHourMinute(event.start) + " - " + dateToHourMinute(event.end), style: TextStyle()),
      ],
    );
  }

  double opacityForIndex(int index) {
    if (index > 9) return 0.2;
    if (index == 0) return 1;
    return 1 - 0.1 * index;
  }
}
