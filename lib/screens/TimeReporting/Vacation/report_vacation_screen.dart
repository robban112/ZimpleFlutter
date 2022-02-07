import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/absence_request.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_vacation_manager.dart';
import 'package:zimple/screens/TimeReporting/add_timereport_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';

class ReportVacationScreen extends StatefulWidget {
  const ReportVacationScreen({Key? key}) : super(key: key);

  @override
  _ReportVacationScreenState createState() => _ReportVacationScreenState();
}

class _ReportVacationScreenState extends State<ReportVacationScreen> {
  late DateTime start;
  late DateTime end;
  late Duration startEndDiff;
  late FirebaseVacationManager firebaseVacationManager;
  AbsenceType? absenceType;
  DateSelectorController startDateController = DateSelectorController();
  DateSelectorController endDateController = DateSelectorController();
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    var now = DateTime.now();
    start = DateTime(now.year, now.month, now.day, 1, 0, 0);
    end = DateTime(now.year, now.month, now.day, 1, 0, 0).add(Duration(days: 7));
    startDateController.initialDate = start;
    endDateController.initialDate = end;
    startEndDiff = end.difference(start);

    super.initState();
  }

  void onChangeStart(DateTime start) {
    setState(() {
      this.start = start;
      startEndDiff = end.difference(start);
    });
  }

  void onChangeEnd(DateTime end) {
    setState(() {
      this.end = end;
      startEndDiff = end.difference(start);
    });
  }

  void uploadVacation() {
    if (this.absenceType == null) return; // TODO: Handle error
    context.loaderOverlay.show();
    UserParameters user = Provider.of<ManagerProvider>(context, listen: false).user;
    FirebaseVacationManager firebaseVacationManager = FirebaseVacationManager(company: user.company);

    firebaseVacationManager.addVacationRequest(user, start, end, notesController.text, this.absenceType!).then((value) {
      context.loaderOverlay.hide();
      Navigator.pop(context);
    });
    // FirebaseEventManager firebaseEventManager =
    //     Provider.of<ManagerProvider>(context, listen: false)
    //         .firebaseEventManager;

    // firebaseEventManager
    //     .addVacationPeriod(user, start, end, notesController.text)
    //     .then((value) {
    //   Navigator.pop(context);
    //   print("Uploaded vacation");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: primaryColor,
        elevation: 5,
        title: Align(alignment: Alignment.centerLeft, child: Text("Ansök om ledighet", style: appBarTitleStyle)),
        leading: NavBarBack(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.0),
                    StartEndDateSelector(
                      startDateSelectorController: startDateController,
                      endDateSelectorController: endDateController,
                      onChangeStart: onChangeStart,
                      onChangeEnd: onChangeEnd,
                      datePickerMode: CupertinoDatePickerMode.date,
                      dateFormat: 'yyyy MMMM dd',
                      startEndFollowSameDay: false,
                    ),
                    //SizedBox(height: 16.0),
                    ListedView(
                        hidesFirstLastSeparator: false,
                        rowInset: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        items: [
                          ListedItem(
                              leadingIcon: Icons.subject,
                              child: Text("Välj typ av frånvaro"),
                              trailingWidget: Row(
                                children: [
                                  absenceType != null ? Text(absenceToString(absenceType!)) : Container(),
                                  Icon(Icons.chevron_right)
                                ],
                              ),
                              onTap: () => pushNewScreen(context, screen: SelectAbsenceType(
                                    didSelectAbsenceType: (absenceType) {
                                      setState(() {
                                        this.absenceType = absenceType;
                                      });
                                      Navigator.pop(context);
                                    },
                                  )))
                        ]),
                    SizedBox(height: 16.0),
                    NotesComponent(controller: notesController),
                    SizedBox(height: 24.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Antal dagar: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
                          Text((startEndDiff.inDays + 1).toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(child: RectangularButton(onTap: () => uploadVacation(), text: "Ansök frånvaro")),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectAbsenceType extends StatelessWidget {
  const SelectAbsenceType({Key? key, required this.didSelectAbsenceType}) : super(key: key);
  final Function(AbsenceType) didSelectAbsenceType;

  @override
  Widget build(BuildContext context) {
    List<AbsenceType> absenceTypes = AbsenceType.values.where((absence) => absence != AbsenceType.unknown).toList();
    return Scaffold(
      appBar: PreferredSize(preferredSize: appBarSize, child: StandardAppBar("Välj typ av frånvaro")),
      body: SingleChildScrollView(
        child: ListedView(
          items: List.generate(absenceTypes.length, (index) {
            AbsenceType absenceType = absenceTypes[index];
            return ListedItem(child: Text(absenceToString(absenceType)), onTap: () => didSelectAbsenceType(absenceType));
          }),
        ),
      ),
    );
  }
}
