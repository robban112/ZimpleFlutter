import 'dart:io';

import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/extensions/double_extensions.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/AddEvent/customer_select_screen.dart';
import 'package:zimple/screens/Calendar/Notes/add_notes_screen.dart/add_notes_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_select_screen.dart';
import 'package:zimple/utils/generic_imports.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';

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
  TextEditingController breakController = TextEditingController();
  BehaviorSubject<double> totalTimeStreamController = BehaviorSubject<double>();
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
    Future.delayed(Duration.zero, () {
      totalTimeStreamController.add(getTotalTime());
    });

    breakController.addListener(() => totalTimeStreamController.add(getTotalTime()));
    logger.log(Level.info, "Init State Add Timereport");
    super.initState();
    firebaseTimeReportManager = Provider.of<ManagerProvider>(context, listen: false).firebaseTimereportManager;
    user = Provider.of<ManagerProvider>(context, listen: false).user;
    firebaseEventManager = Provider.of<ManagerProvider>(context, listen: false).firebaseEventManager;
    firebaseStorageManager = FirebaseStorageManager(company: user.company);
  }

  @override
  void dispose() {
    totalTimeStreamController.close();
    super.dispose();
  }

  double getTotalTime() {
    DateTime start = startDateController.getDate();
    DateTime end = endDateController.getDate();
    int diff = (end.difference(start).inMinutes);
    return (diff - getBreakTime()) / 60;
  }

  int getBreakTime() {
    if (breakController.text.isEmpty) return 0;
    return double.parse(breakController.text).toInt();
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
    totalTimeStreamController.add(getTotalTime());
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
      appBar: appBar("Tidrapportera"),
      body: BackgroundWidget(child: _body(context)),
    );
  }

  GestureDetector _body(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [_buildListedView(context), _buildSelectImagesView()],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              buildDoneButton(context),
              const SizedBox(height: 16),
            ]),
          )
        ],
      ),
    );
  }

  SelectImagesComponent _buildSelectImagesView() {
    return SelectImagesComponent(
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
    );
  }

  Widget _buildListedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //shrinkWrap: true,
        //padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24.0),
        children: [
          ListedTitle(text: "TID"),
          ZSeparator(),
          buildTimeComponent(),
          ListedView(
            items: [
              ListedTextField(
                placeholder: 'Rast',
                leadingIcon: FontAwesome.coffee,
                controller: breakController,
                inputType: TextInputType.number,
              ),
              ListedItem(leadingIcon: Icons.access_time, text: "Arbetad tid", trailingWidget: _buildTotalTimeText())
            ],
          ),
          ZSeparator(),
          const SizedBox(height: 32),
          ListedTitle(text: "ÖVRIG INFO"),
          //buildSelectCustomerTile(),
          ListedView(
            hidesFirstLastSeparator: false,
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
                    PersistentNavBarNavigator.pushNewScreen(context, screen: CustomerSelectScreen(
                      didSelectCustomer: (customer, contact) {
                        setState(() {
                          selectedCustomer = customer;
                        });
                      },
                    ));
                  }),
              ListedItem(
                leadingIcon: Icons.image,
                text: "Bilder",
                onTap: () {
                  setState(() => this.isSelectingPhotoProvider = true);
                },
                trailingWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 150, minWidth: 0, maxHeight: 30),
                        child: PreviewImagesComponent(selectedImages: this.selectedImages)),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListedNotefield(
                context: context,
                numberOfLines: 8,
                item: ListedTextField(placeholder: 'Anteckningar', isMultipleLine: true, controller: notesController)),
          ),
          // ListedItemWidget(
          //   rowInset: EdgeInsets.only(right: 16.0, left: 16.0),
          //   item: ListedItem(
          //     leadingIcon: Icons.image,
          //     text: "Bilder",
          //     onTap: () {
          //       setState(() => this.isSelectingPhotoProvider = true);
          //     },
          //     trailingWidget: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         ConstrainedBox(
          //             constraints: BoxConstraints(maxWidth: 150, minWidth: 0, maxHeight: 50),
          //             child: PreviewImagesComponent(selectedImages: this.selectedImages)),
          //         Icon(Icons.chevron_right)
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: 32.0),
          //buildInfoComponent(),
          //SizedBox(height: 16.0),
          //buildCostComponent(),
          //SizedBox(height: 24.0),
          //_buildPlannedInfoComponent(),
          SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildTotalTimeText() {
    return StreamBuilder<double>(
      initialData: 8,
      stream: totalTimeStreamController.stream,
      builder: (context, snapshot) {
        return Text(snapshot.data?.parseToTwoDigits() ?? "", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
      },
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
                  PersistentNavBarNavigator.pushNewScreen(context,
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
            // NotesComponent(
            //   controller: notesController,
            // ),

            // ListedItemWidget(
            //   rowInset: EdgeInsets.only(right: 16.0, left: 20.0),
            //   item: ListedItem(
            //     leadingIcon: Icons.image,
            //     child: Text("Bilder"),
            //     onTap: () {
            //       setState(() => this.isSelectingPhotoProvider = true);
            //     },
            //     trailingWidget: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       mainAxisAlignment: MainAxisAlignment.end,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         ConstrainedBox(
            //             constraints: BoxConstraints(maxWidth: 150, minWidth: 0, maxHeight: 50),
            //             child: PreviewImagesComponent(selectedImages: this.selectedImages)),
            //         Icon(Icons.chevron_right)
            //       ],
            //     ),
            //   ),
            // ),
            Container(height: 0.5, color: Colors.grey.shade400)
          ],
        )
      ],
    );
  }

  // Widget buildSelectCustomerTile() {
  //   return selectedEvent == null
  //       ? ListedView(
  //           hidesFirstLastSeparator: false,
  //           //rowInset: EdgeInsets.symmetric(horizontal: 12),
  //           items: [
  //             ListedItem(
  //                 leadingIcon: Icons.person,
  //                 child: Text("Kund", style: TextStyle(fontSize: 16)),
  //                 trailingWidget: Row(
  //                   children: [
  //                     Text(selectedCustomer?.name ?? ""),
  //                     selectedCustomer == null ? Icon(Icons.chevron_right) : Container(),
  //                     selectedCustomer != null
  //                         ? GestureDetector(
  //                             onTap: () {
  //                               setState(() {
  //                                 this.selectedCustomer = null;
  //                               });
  //                             },
  //                             child: Icon(Icons.clear))
  //                         : Container()
  //                   ],
  //                 ),
  //                 onTap: () {
  //                   pushNewScreen(context, screen: CustomerSelectScreen(
  //                     didSelectCustomer: (customer, contact) {
  //                       setState(() {
  //                         selectedCustomer = customer;
  //                       });
  //                     },
  //                   ));
  //                 }),
  //           ],
  //         )
  //       : Container();
  // }

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
                SchedulerBinding.instance.addPostFrameCallback((_) {
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
        ZSeparator(padding: EdgeInsets.only(left: 16)),
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
    if (firebaseTimeReportManager == null) {
      return;
    }
    setLoading(true);
    var timereport = TimeReport(
        id: "",
        startDate: startDateController.getDate(),
        endDate: endDateController.getDate(),
        breakTime: getBreakTime(),
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
        showSnackbar(context: context, isSuccess: true, message: "Tidrapport tillagd!");
        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    });
  }

  Widget buildDoneButton(BuildContext context) => Row(
        children: [
          Expanded(child: RectangularButton(onTap: _addTimeReport, text: "Skicka in tidrapport")),
        ],
      );
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

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource);
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
      isSelectingPhotoProvider: this.isSelectingPhotoProvider,
      didTapCancel: didTapCancel,
      didReceiveImage: didPickImage,
    );
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
