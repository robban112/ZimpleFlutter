import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/screens/TimeReporting/timereporting_list_screen.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';

class ShowAllTimeReportScreen extends StatefulWidget {
  const ShowAllTimeReportScreen({Key? key}) : super(key: key);

  @override
  _ShowAllTimeReportScreenState createState() => _ShowAllTimeReportScreenState();
}

class _ShowAllTimeReportScreenState extends State<ShowAllTimeReportScreen> {
  @override
  Widget build(BuildContext context) {
    List<Person> persons = PersonManager.of(context).persons;
    return Scaffold(
      appBar: appBar("Alla Tidrapporter"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Välj person", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
            ),
            ListedView(
              items: List.generate(persons.length, (index) {
                Person person = persons[index];
                return ListedItem(
                    leadingIcon: Icons.person,
                    child: Text(person.name),
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: TimereportingListScreen(
                              // userId: person.id,
                              ));
                    },
                    trailingIcon: Icons.arrow_forward);
              }),
            )
          ],
        ),
      ),
    );
  }
}
