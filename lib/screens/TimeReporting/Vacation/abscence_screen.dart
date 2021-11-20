import 'package:flutter/cupertino.dart';
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

class _AbsenceScreenState extends State<AbsenceScreen> with SingleTickerProviderStateMixin {
  late Future<List<AbsenceRequest>> loadVacation;
  late FirebaseEventManager firebaseEventManager;
  late FirebaseVacationManager firebaseVacationManager;

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 150),
  );

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
    animationController.forward();
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
    animationController.forward();
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
    Future.delayed(Duration(milliseconds: 100), () => animationController.reverse());
    context.loaderOverlay.hide();
  }

  Widget _buildVacationRequests(List<AbsenceRequest> vacationRequests) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.ease,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            vacationRequests.length,
            (index) {
              AbsenceRequest vacationRequest = vacationRequests[index];
              return AbsenceRequestWidget(
                absenceRequest: vacationRequest,
                isApproving: widget.isApproving,
                approveRequest: this.approveVacation,
                disapproveRequest: this.disapproveVacation,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: primaryColor,
          title: Align(
              alignment: Alignment.centerLeft, child: Text("Frånvaro", style: TextStyle(color: Colors.white, fontSize: 28))),
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

class AbsenceRequestWidget extends StatelessWidget {
  final bool isApproving;

  final AbsenceRequest absenceRequest;

  final void Function(AbsenceRequest absenceRequest) approveRequest;

  final void Function(AbsenceRequest absenceRequest) disapproveRequest;

  const AbsenceRequestWidget({
    Key? key,
    required this.isApproving,
    required this.absenceRequest,
    required this.approveRequest,
    required this.disapproveRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildStatus(absenceRequest),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(absenceToString(absenceRequest.absenceType)),
                  buildTitle(context, absenceRequest),
                  absenceRequest.notes.isNotBlank()
                      ? Row(
                          children: [
                            _buildTextColumn("Anteckningar", absenceRequest.notes!),
                          ],
                        )
                      : Container(),
                  SizedBox(height: absenceRequest.notes.isNotBlank() ? 12.0 : 0.0),
                ],
              ),
              Expanded(child: Container()),
              this.isApproving ? _buildActionButtons(absenceRequest) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AbsenceRequest absenceRequest) {
    return Row(
      children: [
        _buildActionButton(
          color: canApprove(absenceRequest) ? Colors.green : Colors.green.withOpacity(0.5),
          icon: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: canApprove(absenceRequest) ? () => this.approveRequest(absenceRequest) : () {},
        ),
        const SizedBox(width: 6),
        _buildActionButton(
          color: canDisapprove(absenceRequest) ? Colors.red : Colors.red.withOpacity(0.5),
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: canDisapprove(absenceRequest) ? () => this.disapproveRequest(absenceRequest) : () {},
        ),
      ],
    );
  }

  bool canApprove(AbsenceRequest absenceRequest) => absenceRequest.approved == null ? true : !absenceRequest.approved!;

  bool canDisapprove(AbsenceRequest absenceRequest) => absenceRequest.approved == null ? true : absenceRequest.approved!;

  CupertinoButton _buildActionButton({
    required Color color,
    required Icon icon,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: icon,
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

  Widget buildTitle(BuildContext context, AbsenceRequest vacationRequest) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Text(
        "${dateString(vacationRequest.startDate)} - ${dateString(vacationRequest.endDate)}",
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget approvedRequest() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green,
          radius: 16,
          child: Icon(
            Icons.check,
            size: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget waitingRequest() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.yellow,
          radius: 16,
          child: Icon(
            Icons.hourglass_bottom,
            size: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget deniedRequest() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.red,
          radius: 16,
          child: Icon(
            Icons.clear,
            size: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildStatus(AbsenceRequest vacationRequest) {
    if (vacationRequest.approved == null) return waitingRequest();
    return vacationRequest.approved! ? approvedRequest() : deniedRequest();
  }

  Widget buildButton(BuildContext context, String title, VoidCallback onTap) {
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
}
