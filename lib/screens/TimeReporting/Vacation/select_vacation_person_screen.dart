import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/screens/TimeReporting/Vacation/abscence_screen.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';
import 'package:zimple/widgets/provider_widget.dart';

class SelectVacationPersonScreen extends StatefulWidget {
  const SelectVacationPersonScreen({Key? key, this.unreadAbsenceMap}) : super(key: key);

  final Map<String, int>? unreadAbsenceMap;
  @override
  SelectVacationPersonScreenState createState() => SelectVacationPersonScreenState();
}

class SelectVacationPersonScreenState extends State<SelectVacationPersonScreen> {
  Widget _buildNumberOfUnreadAbsenceRequests(Map<String, int>? absenceMap, String userId) {
    if (absenceMap == null) return Container();
    if (!absenceMap.containsKey(userId)) return Container();
    int totalUnread = absenceMap[userId]!;
    if (totalUnread <= 0) return Container();
    return CircleAvatar(
      radius: 10,
      backgroundColor: Colors.red,
      child: Text(
        "$totalUnread",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Person> persons = Provider.of<ManagerProvider>(context, listen: true).personManager.persons;
    String company = Provider.of<ManagerProvider>(context, listen: true).user.company;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: StandardAppBar("Välj person"),
      ),
      body: SingleChildScrollView(
          child: ListedView(
        items: List.generate(persons.length, (index) {
          Person person = persons[index];
          return ListedItem(
              leadingIcon: Icons.person,
              child: Text(person.name),
              onTap: () {
                pushNewScreen(context,
                    screen: AbsenceScreen(
                      userId: person.id,
                      company: company,
                      isApproving: true,
                      person: person,
                    ));
              },
              trailingWidget: Row(
                children: [
                  _buildNumberOfUnreadAbsenceRequests(widget.unreadAbsenceMap, person.id),
                  SizedBox(width: 6.0),
                  Icon(Icons.arrow_forward)
                ],
              ));
        }),
      )),
    );
  }
}
