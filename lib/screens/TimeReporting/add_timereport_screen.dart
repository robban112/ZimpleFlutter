import 'dart:io';

import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/AddEvent/customer_select_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_select_screen.dart';
import 'package:zimple/widgets/button/nav_bar_back.dart';
import 'package:zimple/widgets/image_dialog.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';
import 'package:zimple/widgets/photo_buttons.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';

import '../../utils/constants.dart';
import 'Components/timereport_cost_component.dart';

class AddTimeReportingScreen extends StatefulWidget {
  final EventManager eventManager;
  AddTimeReportingScreen({required this.eventManager});

  @override
  _AddTimeReportingScreenState createState() => _AddTimeReportingScreenState();
}

class _AddTimeReportingScreenState extends State<AddTimeReportingScreen> {
  final logger = Logger();
  DateSelectorController startDateController = DateSelectorController();
  DateSelectorController endDateController = DateSelectorController();
  TextEditingController notesController = TextEditingController();
  late FirebaseTimeReportManager firebaseTimeReportManager;
  late FirebaseEventManager firebaseEventManager;
  late FirebaseStorageManager firebaseStorageManager;
  late UserParameters user;
  Event? selectedEvent;
  Customer? selectedCustomer;
  //final <TimereportCostComponentState> _costKey = GlobalKey();
  List<Cost> costs = [];

  final GlobalKey<FormState> _titleFormKey = GlobalKey<FormState>();

  final UniqueKey _startEndKey = UniqueKey();

  bool isSelectingPhotoProvider = false;

  List<File> selectedImages = [];
  int minutesBreak = 0;
  double _minutesBreak = 0;
  Duration startEndDifference = Duration(hours: 0, minutes: 0);

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    logger.log(Level.info, "Init State Add Timereport");
    super.initState();
    firebaseTimeReportManager = Provider.of<ManagerProvider>(context, listen: false).firebaseTimereportManager;
    user = Provider.of<ManagerProvider>(context, listen: false).user;
    firebaseEventManager = Provider.of<ManagerProvider>(context, listen: false).firebaseEventManager;
    firebaseStorageManager = FirebaseStorageManager(company: user.company);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
      child: Text(title, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
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
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(-2, 2), // changes position of shadow
            ),
          ],
        ),
        child: child);
  }

  void setLoading(bool loading) {
    if (loading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Tidrapportera", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.0, color: Colors.white))),
        elevation: 0.0,
        leading: NavBarBack(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
              children: [
                buildChooseWorkOrderComponent(),
                SizedBox(height: 12.0),
                selectedEvent == null ? _buildSectionTitle("Eller välj kund") : Container(),
                buildSelectCustomerTile(),
                SizedBox(height: 32.0),
                buildTimeComponent(),
                SizedBox(height: 32.0),
                buildInfoComponent(),
                SizedBox(height: 16.0),
                buildCostComponent(),
                SizedBox(height: 24.0),
                _buildPlannedInfoComponent(),
                SizedBox(height: 24.0),
                buildDoneButton(context),
                SizedBox(height: 175.0),
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
    );
  }

  Widget buildChooseWorkOrderComponent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.0),
        _buildSectionTitle("Arbetsorder"),
        ListedView(
          hidesFirstLastSeparator: false,
          items: [
            ListedItem(
                leadingIcon: Icons.work,
                child: Text("Välj arbetsorder", style: TextStyle(fontSize: 16)),
                trailingWidget: Row(
                  children: [
                    selectedEvent != null
                        ? ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 150, maxHeight: 17),
                            child: Text(
                              selectedEvent?.title ?? "",
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),
                          )
                        : Container(),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  pushNewScreen(context,
                      screen: TimeReportingSelectScreen(
                        eventManager: widget.eventManager,
                        didSelectEvent: (event) {
                          setState(() {
                            this.selectedEvent = event;
                            this.startDateController.setDate(selectedEvent!.start);
                            this.endDateController.setDate(selectedEvent!.end);
                            updateDifference(startDateController.getDate(), endDateController.getDate(), this.minutesBreak);
                          });
                        },
                      ));
                })
          ],
        ),
      ],
    );
  }

  Column buildInfoComponent() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotesComponent(
              controller: notesController,
            ),
            ListedItemWidget(
              rowInset: EdgeInsets.only(right: 16.0, left: 20.0),
              item: ListedItem(
                leadingIcon: Icons.image,
                child: Text("Bilder"),
                onTap: () {
                  setState(() => this.isSelectingPhotoProvider = true);
                },
                trailingWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 150, minWidth: 0, maxHeight: 50),
                        child: PreviewImagesComponent(selectedImages: this.selectedImages)),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ),
            ),
            Container(height: 0.5, color: Colors.grey.shade400)
          ],
        )
      ],
    );
  }

  Widget buildSelectCustomerTile() {
    return selectedEvent == null
        ? ListedView(
            hidesFirstLastSeparator: false,
            //rowInset: EdgeInsets.symmetric(horizontal: 12),
            items: [
              ListedItem(
                  leadingIcon: Icons.person,
                  child: Text("Kund", style: TextStyle(fontSize: 16)),
                  trailingWidget: Row(
                    children: [
                      Text(selectedCustomer?.name ?? ""),
                      selectedCustomer == null ? Icon(Icons.chevron_right) : Container(),
                      selectedCustomer != null
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  this.selectedCustomer = null;
                                });
                              },
                              child: Icon(Icons.clear))
                          : Container()
                    ],
                  ),
                  onTap: () {
                    pushNewScreen(context, screen: CustomerSelectScreen(
                      didSelectCustomer: (customer, contact) {
                        setState(() {
                          selectedCustomer = customer;
                        });
                      },
                    ));
                  }),
            ],
          )
        : Container();
  }

  Column buildCostComponent() {
    return Column(
      key: UniqueKey(),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Utgifter"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildContainer(TimereportCostComponent(
              costs: this.costs,
              didAddCost: (cost) {
                SchedulerBinding.instance?.addPostFrameCallback((_) {
                  Navigator.pop(context);
                  setState(() {
                    this.costs.add(cost);
                  });
                });
              },
              didRemoveCost: (cost) {
                setState(() {
                  this.costs.remove(cost);
                });
              })),
        )
      ],
    );
  }

  Widget _buildPlannedInfoComponent() {
    if (selectedEvent == null) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Planerad info"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildContainer(Column(
            children: [
              TimereportRow("Personer", Text((selectedEvent?.persons ?? []).map((e) => e.name).toList().toString())),
              TimereportRow("Plats", Text(selectedEvent?.location ?? "")),
              TimereportRow("Kund", Text(selectedEvent?.customer ?? "")),
              TimereportRow("Telefonnummer", Text(selectedEvent?.phoneNumber ?? "")),
              TimereportRow(
                  "Anteckningar",
                  ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
                      child: Text(
                        selectedEvent?.notes ?? "",
                        textAlign: TextAlign.end,
                      ))),
              TimereportRow("Bilder", Text(selectedEvent?.phoneNumber ?? "")),
            ],
          )),
        )
      ],
    );
  }

  Column buildTimeComponent() {
    var now = DateTime.now();
    var start = selectedEvent != null ? selectedEvent!.start : DateTime(now.year, now.month, now.day, 8, 0, 0);
    var end = selectedEvent?.end ?? DateTime(now.year, now.month, now.day, 16, 0, 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Tid"),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 0.5, color: Colors.grey.shade400),
            StartEndDateSelector(
              key: _startEndKey,
              startDateSelectorController: startDateController,
              endDateSelectorController: endDateController,
              onChangeStart: (startDate) => updateDifference(startDate, endDateController.getDate(), this.minutesBreak),
              onChangeEnd: (endDate) => updateDifference(startDateController.getDate(), endDate, this.minutesBreak),
              datePickerMode: selectedEvent != null ? CupertinoDatePickerMode.time : CupertinoDatePickerMode.dateAndTime,
              startTitle: "Började",
              endTitle: "Slutade",
            ),
            Container(height: 0.5, color: Colors.grey.shade400),
            //buildBreakRow(),
            const SizedBox(height: 6),
            buildBreakSlider(),
            const SizedBox(height: 6),
            Container(height: 0.5, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            TimereportRow(
              "Total arbetad tid",
              Text(_getTotalTime(startEndDifference)),
              hidesSeparatorByDefault: true,
            ),
            Container(height: 0.5, color: Colors.grey.shade400),
          ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Rast:", style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Text("${_minutesBreak.toInt()}", style: TextStyle(fontSize: 20.0)),
                  Text(" minuter"),
                ],
              ),
            ],
          ),
        ),
        Slider(
          value: this._minutesBreak,
          min: 0,
          max: 100,
          divisions: 480,
          label: '${_minutesBreak.toInt()}',
          activeColor: Theme.of(context).colorScheme.secondary,
          inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          onChanged: (newValue) {
            setState(() {
              this._minutesBreak = newValue;
              updateDifference(startDateController.getDate(), endDateController.getDate(), newValue.toInt());
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
          keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
          textInputAction: TextInputAction.done,
          onChanged: (minutes) {
            try {
              var intMinutes = int.parse(minutes);
              updateDifference(startDateController.getDate(), endDateController.getDate(), intMinutes);
            } on FormatException {
              updateDifference(startDateController.getDate(), endDateController.getDate(), 0);
            }
          },
        ),
      ),
    );
  }

  Future<void> _setEventTimereported(String timereportId) async {
    var event = selectedEvent;
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

  Future<void> _uploadTimereportImages(List<String> filenames, String? key) async {
    if (key == null) return;
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
        id: "",
        startDate: startDateController.getDate(),
        endDate: endDateController.getDate(),
        breakTime: this.minutesBreak,
        totalTime: startEndDifference.inMinutes,
        eventId: selectedEvent?.id,
        costs: this.costs,
        comment: notesController.text,
        customerKey: selectedCustomer?.id);
    fb.DatabaseReference ref = firebaseTimeReportManager.newTimereportRef();
    var filenames = selectedImages.map((_) => Uuid().v4().toString()).toList();
    timereport.setImagesStoragePaths(ref.key, filenames);
    await _uploadTimereportImages(filenames, ref.key);
    firebaseTimeReportManager.addTimeReport(timereport, user).then((value) {
      _setEventTimereported(value).then((value) {
        setLoading(false);
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    });
  }

  Widget buildDoneButton(BuildContext context) => RectangularButton(onTap: _addTimeReport, text: "Skicka in tidrapport");
}

class TimereportRow extends StatelessWidget {
  final String title;
  final Widget leading;
  final Color color;
  final EdgeInsets rowInset;
  final bool hidesSeparatorByDefault;
  TimereportRow(this.title, this.leading,
      {this.color = Colors.white,
      this.rowInset = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
      this.hidesSeparatorByDefault = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: rowInset,
      child: Container(
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(this.title, style: TextStyle(fontSize: 16.0)),
              this.leading,
            ],
          ),
          Container(height: 15),
          hidesSeparatorByDefault
              ? Container()
              : Container(
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
  PreviewImagesComponent({required this.selectedImages});

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
                showDialog(context: context, builder: (_) => ImageDialog(image: Image.file(image)));
              },
              child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(image, width: 30, fit: BoxFit.cover)),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 5.0);
        });
  }
}

class SelectImagesComponent extends StatelessWidget {
  final bool isSelectingPhotoProvider;
  final Function didTapCancel;
  final Function(File) didPickImage;

  final picker = ImagePicker();

  SelectImagesComponent({required this.isSelectingPhotoProvider, required this.didPickImage, required this.didTapCancel});

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
    return PhotoButtons(
        isSelectingPhotoProvider: this.isSelectingPhotoProvider, didTapCancel: didTapCancel, didReceiveImage: didPickImage);
  }
}

class NotesComponent extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  NotesComponent({required this.controller});

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
      //textInputAction: TextInputAction.done,
      controller: controller,
      enableSuggestions: false,
      autocorrect: false,
      minLines: 10,
      maxLines: 15,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: 'Skriv anteckning ...',
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.zero),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.zero),
        border:
            OutlineInputBorder(borderSide: const BorderSide(width: 0.5, color: Colors.white), borderRadius: BorderRadius.zero),
        focusColor: green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Text("Anteckningar", style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          ),
          _buildTextField(),
        ],
      ),
    );
  }
}
