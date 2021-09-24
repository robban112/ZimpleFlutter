import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/screens/TimeReporting/timereporting_list_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/listed_view.dart';
import 'package:zimple/widgets/provider_widget.dart';

class ShowAllTimeReportScreen extends StatefulWidget {
  const ShowAllTimeReportScreen({Key? key}) : super(key: key);

  @override
  _ShowAllTimeReportScreenState createState() => _ShowAllTimeReportScreenState();
}

class _ShowAllTimeReportScreenState extends State<ShowAllTimeReportScreen> {
  @override
  Widget build(BuildContext context) {
    List<Person> persons = Provider.of<ManagerProvider>(context, listen: true).personManager.persons;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: primaryColor,
        title: Text("Alla tidrapporter", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                      pushNewScreen(context,
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
