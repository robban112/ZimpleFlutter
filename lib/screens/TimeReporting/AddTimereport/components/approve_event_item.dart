import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/TimeReporting/AddTimereport/change_timereport_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/abscence_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/service/user_service.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class ApproveEventItem extends StatelessWidget {
  final Event event;

  const ApproveEventItem({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("rebuilt approve event item");
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
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: _buildActionButtonChildren(context),
    );
  }

  List<Widget> _buildActionButtonChildren(BuildContext context) {
    if (hasUserTimereportedThisEvent(context)) {
      return [Icon(Icons.arrow_right)];
    }
    return [
      Column(
        children: [
          ActionButton(
            color: ThemeNotifier.of(context).isDarkMode() ? Color(0xffFEC260) : Colors.yellow.shade500,
            icon: Icon(FontAwesome.pencil, color: Colors.black),
            onPressed: () => changeEvent(context),
          ),
          const SizedBox(height: 6),
          Text("Ändra", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
        ],
      ),
      if (!hasUserTimereportedThisEvent(context)) const SizedBox(width: 12),
      if (!hasUserTimereportedThisEvent(context))
        Column(
          children: [
            ActionButton(
                color: Colors.green, icon: Icon(Icons.check, color: Colors.white), onPressed: () => approveEvent(context)),
            const SizedBox(height: 6),
            Text("Godkänn", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
    ];
  }

  Widget _buildTitleDescriptionText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.55,
          child: _buildDynamicContent(context),
        ),
      ],
    );
  }

  Widget _buildDynamicContent(BuildContext context) {
    if (hasUserTimereportedThisEvent(context)) {
      TimeReport? timereport = getUserTimereport(context);
      if (timereport == null) return Container();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 6),
          Row(
            children: [
              SuccessIcon(size: Size(24, 24)),
              const SizedBox(width: 4),
              Text("Tidrapporterat:", style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              getTimeBetween(timereport.startDate, timereport.endDate),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          _buildTitle(context),
          const SizedBox(height: 6),
          buildTimeRow(),
          const SizedBox(height: 6),
          _buildProfilePictures(context),
        ],
      );
    }
  }

  Widget _buildTitle(BuildContext context) {
    if (event.customerKey == null) return _title(event.title);
    Customer? customer = ManagerProvider.of(context).customerManager.getCustomer(event.customerKey!);
    if (customer == null) return _title(event.title);
    return _title(customer.name + " • " + event.title);
  }

  Text _title(String text) => Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _buildProfilePictures(BuildContext context) {
    if (event.persons == null) return Container();
    List<Person> persons = event.persons!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 20,
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
        Text(
            getHourDiffPresentable(event.start, event.end) +
                " tim | " +
                dateToHourMinute(event.start) +
                " - " +
                dateToHourMinute(event.end),
            style: TextStyle()),
      ],
    );
  }

  Widget getTimeBetween(DateTime start, DateTime end) {
    return Text(
      dateToHourMinute(start) + " - " + dateToHourMinute(end),
    );
  }

  double opacityForIndex(int index) {
    if (index > 9) return 0.2;
    if (index == 0) return 1;
    return 1 - 0.1 * index;
  }

  bool hasUserTimereportedThisEvent(BuildContext context) {
    User user = UserService.of(context).user!;
    print("timereported ${event.id}: " + event.timereports.toString());
    return event.timereports.keys.contains(user.uid);
  }

  void approveEvent(BuildContext context) async {
    FirebaseTimeReportManager firebaseTimeReportManager = ManagerProvider.of(context).firebaseTimereportManager;
    UserParameters user = ManagerProvider.of(context).user;
    // List<String> newTimereportedList = List.from(event.timereported);
    // newTimereportedList.add(user.token);

    String key = await firebaseTimeReportManager.addTimeReport(TimeReport.fromEvent(event), user);

    Map<String, String> timereports = Map.from(event.timereports);
    timereports[user.token] = key;
    Event newEvent = event.copyWith(timereports: timereports);

    await ManagerProvider.of(context).firebaseEventManager.changeEvent(newEvent).then((value) {
      showSnackbar(context: context, isSuccess: true, message: "Tidrapport tillagd!");
    });
  }

  TimeReport? getUserTimereport(BuildContext context) {
    User user = UserService.of(context).user!;
    String? timereportId = event.timereports[user.uid];
    if (timereportId == null) return null;
    TimeReport? timereport = ManagerProvider.of(context).timereportManager.getTimereport(timereportId, user.uid);
    return timereport;
  }

  void changeEvent(BuildContext context) {
    if (hasUserTimereportedThisEvent(context)) {
      TimeReport? timereport = getUserTimereport(context);
      if (timereport == null) {
        _showError(context);
        return;
      }
      pushNewScreen(context, screen: ChangeTimereportScreen(timereport: timereport, isChangingTimereport: true));
    } else {
      pushNewScreen(
        context,
        screen: ChangeTimereportScreen(
          timereport: TimeReport.fromEvent(event),
          isChangingTimereport: false,
        ),
      );
    }
  }

  void _showError(BuildContext context) {
    showSnackbar(context: context, isSuccess: false, message: "Kunde inte ändra tidrapport");
  }
}
