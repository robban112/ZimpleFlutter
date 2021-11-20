import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/absence_request.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_vacation_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/widgets/provider_widget.dart';

class AbsenceScreen extends StatefulWidget {
  const AbsenceScreen({Key? key, this.isApproving = false, this.person, required this.userId, required this.company})
      : super(key: key);

  final Person? person;
  final String userId;
  final String company;
  final bool isApproving;
  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  late Future<List<AbsenceRequest>> loadVacation;
  late FirebaseEventManager firebaseEventManager;
  late FirebaseVacationManager firebaseVacationManager;
  @override
  void initState() {
    loadVacation = _loadVacation();
    firebaseVacationManager = FirebaseVacationManager(company: widget.company);
    super.initState();
    firebaseEventManager = Provider.of<ManagerProvider>(context, listen: false).firebaseEventManager;
  }

  Future<List<AbsenceRequest>> _loadVacation() {
    return FirebaseVacationManager(company: widget.company).getVacationRequests(widget.userId);
  }

  Future<void> changeVacation(BuildContext context, AbsenceRequest vacationRequest) async {
    return firebaseVacationManager.changeVacationRequest(vacationRequest);
  }

  void disapproveVacation(AbsenceRequest vacationRequest) async {
    context.loaderOverlay.show();
    if (vacationRequest.eventIds != null) {
      await firebaseEventManager.removeEventsIds(vacationRequest.eventIds!);
      vacationRequest.eventIds = null;
    }

    vacationRequest.approved = false;
    await changeVacation(context, vacationRequest);
    afterVacationStateChange();
  }

  void approveVacation(AbsenceRequest vacationRequest) async {
    if (vacationRequest.eventIds != null) return;

    context.loaderOverlay.show();

    await firebaseEventManager.addVacationPeriod(vacationRequest, widget.person?.name).then((List<String> eventIds) {
      print("Uploaded vacation");

      vacationRequest.approved = true;
      vacationRequest.eventIds = eventIds;
      changeVacation(context, vacationRequest);
    });
    afterVacationStateChange();
  }

  void afterVacationStateChange() async {
    await firebaseVacationManager.getUnreadAbsenceRequests().then((absenceMap) {
      Provider.of<ManagerProvider>(context, listen: false).absenceRequestReadMap = absenceMap;
    });
    setState(() {
      loadVacation = _loadVacation();
    });
    context.loaderOverlay.hide();
  }

  Widget approvedRequest() {
    return Row(
      children: [
        CircleAvatar(backgroundColor: Colors.green, radius: 10, child: Icon(Icons.check, size: 14, color: Colors.white)),
        SizedBox(width: 12.0),
        _buildTextColumn("Status", "Godkänd")
      ],
    );
  }

  Widget waitingRequest() {
    return Row(
      children: [
        CircleAvatar(
            backgroundColor: Colors.yellow, radius: 10, child: Icon(Icons.hourglass_bottom, size: 12, color: Colors.black)),
        SizedBox(width: 12.0),
        _buildTextColumn("Status", "Väntar")
      ],
    );
  }

  Widget deniedRequest() {
    return Row(
      children: [
        CircleAvatar(backgroundColor: Colors.red, radius: 10, child: Icon(Icons.clear, size: 14, color: Colors.white)),
        SizedBox(width: 12.0),
        _buildTextColumn("Status", "Obeviljad")
      ],
    );
  }

  Widget buildStatus(AbsenceRequest vacationRequest) {
    if (vacationRequest.approved == null) return waitingRequest();
    return vacationRequest.approved! ? approvedRequest() : deniedRequest();
  }

  Widget buildButton(String title, VoidCallback onTap) {
    return MaterialButton(
      //color: Colors.grey.shade200,
      color: Theme.of(context).colorScheme.secondary,
      elevation: 0.0,
      child: Text(title, style: TextStyle(color: Colors.white)),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Column _buildTextColumn(String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: greyText,
        ),
        SizedBox(
          width: 25,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16.0,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 10,
        )
      ],
    );
  }

  Widget _buildVacationRequests(List<AbsenceRequest> vacationRequests) {
    return SingleChildScrollView(
        child: Column(
            children: List.generate(vacationRequests.length, (index) {
      AbsenceRequest vacationRequest = vacationRequests[index];
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          //height: 90,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(-2, 2), // changes position of shadow
                  )
                ],
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildTitle(vacationRequest),
                  SizedBox(height: 12.0),
                  vacationRequest.notes.isNotBlank()
                      ? Row(
                          children: [
                            _buildTextColumn("Anteckningar", vacationRequest.notes!),
                          ],
                        )
                      : Container(),
                  SizedBox(height: vacationRequest.notes.isNotBlank() ? 12.0 : 0.0),
                  Row(
                    children: [
                      buildStatus(vacationRequest),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      getAbsenceTypeWidget(vacationRequest.absenceType),
                      SizedBox(width: 12.0),
                      _buildTextColumn("Typ", absenceToString(vacationRequest.absenceType))
                    ],
                  ),
                  SizedBox(height: 8.0),
                  widget.isApproving
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildButton("Godkänn", () => approveVacation(vacationRequest)),
                            SizedBox(width: 12.0),
                            buildButton("Neka", () => disapproveVacation(vacationRequest))
                          ],
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      );
    })));
  }

  Text buildTitle(AbsenceRequest vacationRequest) {
    return Text("${dateString(vacationRequest.startDate)} - ${dateString(vacationRequest.endDate)}",
        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: primaryColor,
          title: Align(alignment: Alignment.centerLeft, child: Text("")),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: FutureBuilder(
            future: loadVacation,
            builder: (context, AsyncSnapshot<List<AbsenceRequest>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      "Det verkar inte finnas några frånvaroansökningar kopplat till den här personen",
                      textAlign: TextAlign.center,
                    )),
                  );
                }
                return _buildVacationRequests(snapshot.data!);
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            }));
  }
}
