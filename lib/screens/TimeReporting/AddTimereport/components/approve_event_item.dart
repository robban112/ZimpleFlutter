import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/TimeReporting/AddTimereport/change_timereport_screen.dart';
import 'package:zimple/screens/TimeReporting/Vacation/abscence_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/service/user_service.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class ApproveEventItem extends StatelessWidget {
  final Event event;

  const ApproveEventItem({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (event.eventType != EventType.event) return Container();
    return CupertinoButton(
      key: ValueKey(event.id.hashCode ^ event.timereported.hashCode),
      padding: EdgeInsets.zero,
      onPressed: () => goToChangeTimereport(context),
      child: Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePicture(context),
                      const SizedBox(width: 6),
                      _buildTitle(context),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDescriptionText(context),
                ],
              ),
              const SizedBox(width: 6),
              _buildActionButtons(context),
            ],
          ),
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
      return [
        Text("Ändra",
            style: TextStyle(color: ThemeNotifier.of(context).textColor.withOpacity(0.5), fontSize: 12, fontFamily: 'FiraSans')),
        const SizedBox(width: 8),
        _nextIcon(context)
      ];
    }
    return [
      if (!hasUserTimereportedThisEvent(context)) const SizedBox(width: 12),
      if (!hasUserTimereportedThisEvent(context))
        Column(
          children: [
            ActionButton(
                color: Colors.green,
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () => approveEvent(context)),
            // const SizedBox(height: 6),
            // Text("Godkänn", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
    ];
  }

  Widget _nextIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeNotifier.of(context).textColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NextArrow(),
        ),
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedSwitcher(
                key: UniqueKey(),
                duration: const Duration(milliseconds: 300),
                child: _buildDynamicDescription(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicDescription(BuildContext context) {
    if (hasUserTimereportedThisEvent(context)) {
      TimeReport? timereport = getUserTimereport(context);
      if (timereport == null) return Container();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SuccessIcon(size: const Size(18, 18)),
              const SizedBox(width: 8),
              Text("Tidrapporterat:",
                  style: TextStyle(
                      fontSize: 14,
                      color: ThemeNotifier.of(context).textColor,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'FiraSans')),
              const SizedBox(width: 4),
              getTimeBetween(timereport.startDate, timereport.endDate),
            ],
          ),
        ],
      );
    } else {
      return buildTimeRow();
    }
  }

  Widget _buildTitle(BuildContext context) {
    if (event.customerKey == null) return _title(context, event.title);
    Customer? customer = ManagerProvider.of(context).customerManager.getCustomer(event.customerKey!);
    if (customer == null) return _title(context, event.title);
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: _title(context, customer.name + " • " + event.title),
    );
  }

  Text _title(BuildContext context, String text) => Text(text,
      maxLines: 3,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: ThemeNotifier.of(context).textColor, fontFamily: 'FiraSans'));

  Widget _buildProfilePicture(BuildContext context) {
    Person? person = ManagerProvider.of(context).getLoggedInPerson();
    return ProfilePictureIcon(
      person: person,
      size: Size(24, 24),
    );
  }

  Widget buildTimeRow() {
    if (event.eventType == EventType.vacation) {
      return Container();
    }
    return TimeBetweenText(
      start: event.start,
      end: event.end,
      withHours: true,
    );
  }

  Widget getTimeBetween(DateTime start, DateTime end) {
    return TimeBetweenText(start: start, end: end);
  }

  double opacityForIndex(int index) {
    if (index > 9) return 0.2;
    if (index == 0) return 1;
    return 1 - 0.1 * index;
  }

  bool hasUserTimereportedThisEvent(BuildContext context) {
    User user = UserService.of(context).user!;
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

  void goToChangeTimereport(BuildContext context) {
    if (hasUserTimereportedThisEvent(context)) {
      TimeReport? timereport = getUserTimereport(context);
      if (timereport == null) {
        _showError(context);
        return;
      }
      PersistentNavBarNavigator.pushNewScreen(context,
          screen: ChangeTimereportScreen(
            timereport: timereport,
            isChangingTimereport: true,
            event: event,
          ));
    } else {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ChangeTimereportScreen(
          event: event,
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
