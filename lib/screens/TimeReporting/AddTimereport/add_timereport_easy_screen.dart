import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/screens/TimeReporting/AddTimereport/components/approve_event_item.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/service/user_service.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class AddTimereportEasyScreen extends StatefulWidget {
  const AddTimereportEasyScreen({Key? key}) : super(key: key);

  @override
  _AddTimereportEasyScreenState createState() => _AddTimereportEasyScreenState();
}

class _AddTimereportEasyScreenState extends State<AddTimereportEasyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(appBarHeight), child: StandardAppBar("Rapportera")),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView.builder(
      itemBuilder: (context, index) {
        DateTime date = DateTime.now().subtract(Duration(days: index));

        return TimereportDayListView(date: date);
      },
    );
  }
}

class TimereportDayListView extends StatefulWidget {
  final DateTime date;

  TimereportDayListView({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  _TimereportDayListViewState createState() => _TimereportDayListViewState();
}

class _TimereportDayListViewState extends State<TimereportDayListView> {
  DateFormat formatter = DateFormat('MMMM dd', locale);
  @override
  Widget build(BuildContext context) {
    List<Event> events = ManagerProvider.watch(context).eventManager.getEventsByDate(widget.date, eventFilter: eventFilter);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(events),
          SizedBox(height: events.length > 0 ? 12 : 0),
          _buildApproveEventList(events),
        ],
      ),
    );
  }

  Widget _buildApproveEventList(List<Event> events) {
    if (events.length == 0) {
      return _buildNoEventsText();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Event event = events[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ApproveEventItem(event: event),
        );
      },
      itemCount: events.length,
    );
  }

  Widget _buildNoEventsText() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        "Inga arbetsordrar",
        style: TextStyle(
          color: ThemeNotifier.of(context).textColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Row _buildTitle(List<Event> events) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(getDateTitle(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(width: 12),
        if (events.length > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text("${events.length.toString()} ${getAppendText(events)}",
                style: TextStyle(fontSize: 12, color: ThemeNotifier.of(context).textColor.withOpacity(0.4))),
          )
      ],
    );
  }

  String getDateTitle() {
    if (isToday(widget.date)) return "Idag";
    if (isYesterday(widget.date)) return "Igår";

    return formatter.format(widget.date).capitalize();
  }

  String getAppendText(List<Event> events) => events.length > 1 ? "arbetsordrar" : "arbetsorder";

  List<Event> eventFilter(List<Event> events) {
    String? uid = UserService.of(context).user?.uid;
    if (uid == null) {
      FirebaseCrashlytics.instance.log('UID is null in addtimereporteasy');
      return [];
    }
    return events.where((event) => event.persons?.any((person) => person.id == uid) ?? false).toList();
  }
}
