import 'dart:io';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/widgets/image_dialog.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';
import '../../utils/constants.dart';
import 'Components/timereport_cost_component.dart';

class AddTimeReportingScreen extends StatefulWidget {
  final Event selectedEvent;
  AddTimeReportingScreen({this.selectedEvent});

  @override
  _AddTimeReportingScreenState createState() => _AddTimeReportingScreenState();
}

class _AddTimeReportingScreenState extends State<AddTimeReportingScreen> {
  DateSelectorController startDateController = DateSelectorController();
  DateSelectorController endDateController = DateSelectorController();
  TimereportCostController costController = TimereportCostController();
  TextEditingController notesController = TextEditingController();
  FirebaseTimeReportManager firebaseTimeReportManager;
  FirebaseEventManager firebaseEventManager;
  FirebaseStorageManager firebaseStorageManager;
  UserParameters user;

  final GlobalKey<FormState> _titleFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _imagesFormKey = GlobalKey<FormState>();
  bool isSelectingPhotoProvider = false;

  List<File> selectedImages = [];
  int minutesBreak = 0;
  double _minutesBreak = 0;
  Duration startEndDifference = Duration(hours: 0, minutes: 0);
  bool _uploadingTimereport = false;

  @override
  void initState() {
    super.initState();
    firebaseTimeReportManager =
        Provider.of<ManagerProvider>(context, listen: false)
            .firebaseTimereportManager;
    user = Provider.of<ManagerProvider>(context, listen: false).user;
    firebaseEventManager = Provider.of<ManagerProvider>(context, listen: false)
        .firebaseEventManager;
    firebaseStorageManager = FirebaseStorageManager(company: user.company);
  }

  @override
  void dispose() {
    super.dispose();
    startDateController = null;
    endDateController = null;
  }

  Widget _buildSectionTitle(String title, {IconData leadingIcon}) {
    var style = TextStyle(
        color: primaryColor, fontSize: 18.0, fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Row(
        children: [
          leadingIcon != null ? Icon(leadingIcon) : Container(),
          leadingIcon != null ? SizedBox(width: 5.0) : Container(),
          Text(title, style: style),
        ],
      ),
    );
  }

  String _getTotalTime(Duration difference) {
    var hours = difference.inHours;
    var minutes = difference.inMinutes;
    minutes -= hours * 60;
    if (hours == 0 && minutes == 0) {
      return "";
    } else if (minutes == 0) {
      return "$hours timmar";
    } else {
      return "$hours timmar $minutes minuter";
    }
  }

  void updateDifference(DateTime start, DateTime end, int breakTime) {
    setState(() {
      this.minutesBreak = breakTime;
      end = end.subtract(Duration(minutes: breakTime));
      startEndDifference = end.difference(start);
    });
  }

  Container _buildContainer(Widget child) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(-2, 2), // changes position of shadow
            ),
          ],
        ),
        child: child);
  }

  void setLoading(bool loading) {
    setState(() {
      _uploadingTimereport = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Tidrapportera",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.white))),
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: backgroundColor,
      body: ModalProgressHUD(
        inAsyncCall: _uploadingTimereport,
        opacity: 0.5,
        progressIndicator: CircularProgressIndicator(),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                children: [
                  buildTimeComponent(),
                  SizedBox(height: 24.0),
                  buildInfoComponent(),
                  SizedBox(height: 16.0),
                  buildCostComponent(),
                  SizedBox(height: 24.0),
                  _buildPlannedInfoComponent(),
                  SizedBox(height: 24.0),
                  buildDoneButton(context),
                  SizedBox(height: 48.0),
                ],
              ),
              SelectImagesComponent(
                isSelectingPhotoProvider: this.isSelectingPhotoProvider,
                didPickImage: (file) {
                  setState(() {
                    this.isSelectingPhotoProvider = false;
                    this.selectedImages.add(file);
                  });
                },
                didTapCancel: () {
                  setState(() => this.isSelectingPhotoProvider = false);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Column buildInfoComponent() {
    return Column(
      children: [
        _buildSectionTitle("Information"),
        _buildContainer(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotesComponent(
              controller: notesController,
            ),
            TimereportRow(
                "Lägg till bild",
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: 150, minWidth: 0, maxHeight: 50),
                        child: PreviewImagesComponent(
                            selectedImages: this.selectedImages)),
                    IconButton(
                      color: primaryColor,
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() => this.isSelectingPhotoProvider = true);
                      },
                    ),
                  ],
                ))
          ],
        ))
      ],
    );
  }

  Column buildCostComponent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Utgifter", leadingIcon: Icons.attach_money),
        _buildContainer(TimereportCostComponent(
          timereportCostController: costController,
        )),
      ],
    );
  }

  Widget _buildPlannedInfoComponent() {
    if (widget.selectedEvent == null) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Planerad info"),
        _buildContainer(Column(
          children: [
            TimereportRow(
                "Personer",
                Text(widget.selectedEvent.persons
                    .map((e) => e.name)
                    .toList()
                    .toString())),
            TimereportRow("Plats", Text(widget.selectedEvent.location)),
            TimereportRow("Kund", Text(widget.selectedEvent.customer)),
            TimereportRow(
                "Telefonnummer", Text(widget.selectedEvent.phoneNumber)),
            TimereportRow("Anteckningar", Text(widget.selectedEvent.notes)),
            TimereportRow("Bilder", Text(widget.selectedEvent.phoneNumber)),
          ],
        ))
      ],
    );
  }

  Column buildTimeComponent() {
    var now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Tid", leadingIcon: Icons.access_time),
        _buildContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StartEndDateSelector(
                  widget.selectedEvent?.start ??
                      DateTime(now.year, now.month, now.day, 8, 0, 0),
                  widget.selectedEvent?.end ??
                      DateTime(now.year, now.month, now.day, 16, 0, 0),
                  startDateController,
                  endDateController, (startDate) {
                updateDifference(
                    startDate, endDateController.getDate(), this.minutesBreak);
              }, (endDate) {
                updateDifference(
                    startDateController.getDate(), endDate, this.minutesBreak);
              }),
              //buildBreakRow(),
              buildBreakSlider(),
              TimereportRow(
                  "Total tid", Text(_getTotalTime(startEndDifference)))
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBreakSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          child: Row(
            children: [
              Text("Rast:  "),
              Text("${_minutesBreak.toInt()}",
                  style: TextStyle(fontSize: 20.0)),
              Text(" minuter")
            ],
          ),
        ),
        Slider(
          value: this._minutesBreak,
          min: 0,
          max: 100,
          divisions: 480,
          label: '${_minutesBreak.toInt()}',
          activeColor: green,
          onChanged: (newValue) {
            setState(() {
              this._minutesBreak = newValue;
              updateDifference(startDateController.getDate(),
                  endDateController.getDate(), newValue.toInt());
            });
          },
        ),
      ],
    );
  }

  TimereportRow buildBreakRow() {
    return TimereportRow(
      "Rast (minuter)",
      SizedBox(
        height: 20,
        width: 75,
        child: TextField(
          key: _titleFormKey,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          textInputAction: TextInputAction.done,
          onChanged: (minutes) {
            try {
              var intMinutes = int.parse(minutes) ?? 0;
              updateDifference(startDateController.getDate(),
                  endDateController.getDate(), intMinutes);
            } on FormatException {
              updateDifference(startDateController.getDate(),
                  endDateController.getDate(), 0);
            }
          },
        ),
      ),
    );
  }

  Future<void> _setEventTimereported() async {
    var event = widget.selectedEvent;
    if (event != null) {
      if (event.timereported == null) {
        event.timereported = [user.token];
      } else {
        if (!event.timereported.contains(user.token)) {
          event.timereported.add(user.token);
        }
      }
      await firebaseEventManager.changeEvent(event);
    }
  }

  Future<void> _uploadTimereportImages(
      List<String> filenames, String key) async {
    filenames.asMap().forEach((index, filename) async {
      print("Uploading $filename for timereport $key");
      var file = selectedImages[index];
      await firebaseStorageManager.uploadTimereportImage(key, file, filename);
    });
  }

  void _addTimeReport() async {
    print("Uploading new timereport");
    if (user == null || firebaseTimeReportManager == null) {
      return;
    }
    setLoading(true);
    var timereport = TimeReport(
        startDate: startDateController.getDate(),
        endDate: endDateController.getDate(),
        breakTime: this.minutesBreak,
        totalTime: startEndDifference.inMinutes,
        eventId: widget.selectedEvent?.id,
        costs: costController.getCosts(),
        comment: notesController.text);
    fb.DatabaseReference ref = firebaseTimeReportManager.newTimereportRef();
    var filenames = selectedImages.map((_) => Uuid().v4().toString()).toList();
    timereport.setImagesStoragePaths(ref.key, filenames);
    await _uploadTimereportImages(filenames, ref.key);
    firebaseTimeReportManager.addTimeReport(timereport, user).then((value) {
      _setEventTimereported().then((value) {
        setLoading(false);
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    });
  }

  Widget buildDoneButton(BuildContext context) {
    return RectangularButton(
        onTap: _addTimeReport, text: "Skicka in tidrapport");
  }
}

class TimereportRow extends StatelessWidget {
  final String title;
  final Widget leading;
  TimereportRow(this.title, this.leading);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(this.title, style: TextStyle(fontSize: 15.0)),
                  this.leading
                ],
              ),
              Container(height: 15),
              Container(
                color: Colors.grey.shade300,
                height: 1,
              ),
            ],
          )),
    );
  }
}

class PreviewImagesComponent extends StatelessWidget {
  final List<File> selectedImages;
  PreviewImagesComponent({this.selectedImages});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: selectedImages.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var image = selectedImages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => ImageDialog(image: Image.file(image)));
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(image, width: 30, fit: BoxFit.cover)),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(width: 5.0);
        });
  }
}

class SelectImagesComponent extends StatelessWidget {
  final bool isSelectingPhotoProvider;
  final Function didTapCancel;
  final Function(File) didPickImage;

  final picker = ImagePicker();

  SelectImagesComponent(
      {this.isSelectingPhotoProvider, this.didPickImage, this.didTapCancel});

  Widget _buildPhotoButton(Function onTap, String text) {
    return Container(
      height: 60.0,
      width: 120,
      child: ButtonTheme(
        height: 60.0,
        child: ElevatedButton(
          child: Text(text, style: TextStyle(fontSize: 17.0)),
          onPressed: () {
            onTap();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100.0, 50.0),
            elevation: 5,
            primary: Colors.white,
            onPrimary: Colors.black,
          ),
        ),
      ),
    );
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);
    if (pickedFile != null) {
      print("Picked Image");
      didPickImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        bottom: isSelectingPhotoProvider ? 16 : -300,
        right: 16.0,
        left: 16.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoButton(() {
              getImage(ImageSource.camera);
            }, "Ta foto"),
            SizedBox(height: 1.0),
            _buildPhotoButton(() {
              getImage(ImageSource.gallery);
            }, "Välj foto"),
            SizedBox(height: 5.0),
            _buildPhotoButton(() {
              didTapCancel();
            }, "Avbryt"),
          ],
        ));
  }
}

class NotesComponent extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NotesComponent({this.controller});

  Widget divider() {
    return Column(
      children: [
        SizedBox(height: 5.0),
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: controller,
      maxLines: 7,
      key: _formKey,
      decoration: InputDecoration(
          border: InputBorder.none, enabledBorder: InputBorder.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Anteckningar",
              style: TextStyle(color: Colors.grey.shade800, fontSize: 14.0)),
          divider(),
          _buildTextField(),
          divider(),
        ],
      ),
    );
  }
}
