import 'dart:io';

import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/event_type.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/screens/Calendar/AddEvent/customer_select_screen.dart';
import 'package:zimple/screens/Calendar/AddEvent/person_select_screen.dart';
import 'package:zimple/widgets/image_dialog.dart';
import 'package:zimple/widgets/listed_view.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/utils/constants.dart';
import 'package:collection/collection.dart';
import 'package:zimple/extensions/string_extensions.dart';

class AddEventScreen extends StatefulWidget {
  static const String routeName = 'add_event_screen';
  final List<Person> persons;
  final FirebaseEventManager firebaseEventManager;
  final FirebaseStorageManager firebaseStorageManager;
  final Event? eventToChange;
  AddEventScreen(
      {required this.persons,
      required this.firebaseEventManager,
      required this.firebaseStorageManager,
      this.eventToChange});
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late DateTime startDate;
  late DateTime endDate;
  EdgeInsets contentPadding =
      EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0);
  List<Person> selectedPersons = [];
  String title = "";
  String? phoneNumber;
  String? notes;
  String? customer;
  String? location;
  Customer? selectedCustomer;
  int? selectedCustomerContactPerson;

  late bool changingEvent;
  bool isSelectingPhotoProvider = false;

  final picker = ImagePicker();
  List<File> selectedImages = [];
  File? _image;

  final GlobalKey<FormState> _titleFormKey = GlobalKey<FormState>();
  //final GlobalKey<FormState> _startTimeFormKey = GlobalKey<FormState>();
  //final GlobalKey<FormState> _endTimeFormKey = GlobalKey<FormState>();
  //final GlobalKey<FormState> _personsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _companyFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _notesFormKey = GlobalKey<FormState>();
  //final GlobalKey<FormState> _imagesFormKey = GlobalKey<FormState>();

  final TextEditingController locationController = TextEditingController();
  final TextEditingController phonenumberController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  final DateSelectorController startDateController = DateSelectorController();
  final DateSelectorController endDateController = DateSelectorController();

  static const fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    changingEvent = widget.eventToChange != null;
    if (changingEvent) {
      startDate = widget.eventToChange!.start;
      endDate = widget.eventToChange!.end;
      startDateController.initialDate = startDate;
      endDateController.initialDate = endDate;
      title = widget.eventToChange?.title ?? "";
      phonenumberController.text = widget.eventToChange?.phoneNumber ?? "";
      notes = widget.eventToChange?.notes;
      companyController.text = widget.eventToChange?.customer ?? "";
      locationController.text = widget.eventToChange?.location ?? "";
      selectedPersons = widget.eventToChange?.persons ?? [];

      List<Customer> customers =
          Provider.of<ManagerProvider>(context, listen: false).customers;
      if (widget.eventToChange?.customerKey != null &&
          widget.eventToChange?.customerKey != "") {
        selectedCustomer = customers
            .firstWhereOrNull((c) => c.id == widget.eventToChange?.customerKey);
        selectedCustomerContactPerson =
            widget.eventToChange?.customerContactIndex ?? 0;
      }
    } else {
      startDate = DateTime(now.year, now.month, now.day, 8, 0, 0);
      endDate = DateTime(now.year, now.month, now.day, 16, 0, 0);
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    phonenumberController.dispose();
    companyController.dispose();
    super.dispose();
  }

  void selectPersons(List<Person> persons) {
    setState(() {
      selectedPersons = persons;
    });
  }

  Widget _buildTextField(
      String hintText,
      Widget? leading,
      TextInputType inputType,
      double fontSize,
      Color focusColor,
      Function(String) onChanged,
      GlobalKey<FormState> key,
      String initialValue,
      TextEditingController? controller) {
    return ListTile(
      leading: leading,
      title: Row(
        children: <Widget>[
          SizedBox(width: 12.0),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.done,
              initialValue: initialValue,
              key: key,
              style: TextStyle(fontSize: fontSize),
              autocorrect: false,
              keyboardType: inputType,
              onChanged: onChanged,
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: fontSize),
                focusColor: focusColor,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.0),
        ],
      ),
      contentPadding: contentPadding,
    );
  }

  String getTitle() {
    if (this.title != "") return this.title;
    String agg = "";
    if (companyController.text.isNotBlank()) {
      agg += companyController.text + " - ";
    }
    if (selectedPersons.isNotEmpty) {
      agg += selectedPersons.map((p) => p.name).join(", ");
    }
    return agg;
  }

  Event _getNewEvent() {
    var customerKey = selectedCustomer != null ? selectedCustomer!.id : null;
    return Event(
        id: widget.eventToChange?.id ?? "",
        title: getTitle(),
        start: this.startDateController.getDate(),
        eventType: EventType.event,
        end: this.endDateController.getDate(),
        persons: this.selectedPersons,
        phoneNumber: phonenumberController.text,
        notes: this.notes,
        location: locationController.text,
        customer: companyController.text,
        customerKey: customerKey,
        customerContactIndex: this.selectedCustomerContactPerson);
  }

  Widget _buildNotesTextField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: _notesFormKey,
            //textInputAction: TextInputAction.done,
            enableSuggestions: false,
            autocorrect: false,
            minLines: 10,
            maxLines: 15,
            keyboardType: TextInputType.multiline,
            onChanged: (notes) {
              this.notes = notes;
            },
            initialValue: this.notes,
            decoration: InputDecoration(
              hintText: 'Skriv anteckning ...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey.shade300),
                  borderRadius: BorderRadius.zero),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.grey.shade300),
                  borderRadius: BorderRadius.zero),
              border: OutlineInputBorder(
                  borderSide: const BorderSide(width: 0.5, color: Colors.white),
                  borderRadius: BorderRadius.zero),
              focusColor: green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
      child: Text(title,
          style: TextStyle(
              color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
    );
  }

  Event _uploadEventImages(String key) {
    List<String> fileUids =
        selectedImages.map((_) => Uuid().v4().toString()).toList();
    Map<String, Map<String, String>> map = {};
    fileUids.forEach((fileName) {
      Map<String, String> inner_map = {
        'storagePath': "/Events/${key}/${fileName}"
      };
      var uuid = Uuid().v4().toString();
      map[uuid] = inner_map;
    });
    selectedImages.asMap().forEach((index, file) async {
      var fileName = fileUids[index];
      await widget.firebaseStorageManager.uploadEventImage(key, file, fileName);
    });
    var event = _getNewEvent();
    event.originalImageStoragePaths = map;
    return event;
  }

  void _addNewEvent() async {
    fb.DatabaseReference ref = widget.firebaseEventManager.newEventRef();
    Event event = _uploadEventImages(ref.key);
    print("Adding new event");
    context.loaderOverlay.show();
    widget.firebaseEventManager.addEventWithRef(ref, event).then((value) {
      context.loaderOverlay.hide();
      Navigator.pop(context);
    });
  }

  void _changeEvent() async {
    print("Changing event with id: ${widget.eventToChange?.id}");
    Event event = _uploadEventImages(widget.eventToChange!.id);
    context.loaderOverlay.show();
    widget.firebaseEventManager.changeEvent(event).then((value) {
      context.loaderOverlay.hide();
      Navigator.pop(context);
    });
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 18.0),
        child: Row(
          children: [
            Expanded(
                child: RectangularButton(
                    onTap: changingEvent ? _changeEvent : _addNewEvent,
                    text: "Spara"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        backgroundColor: primaryColor,
        title: Text(changingEvent ? "Ändra arbetsorder" : "Ny arbetsorder"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                      "Titel", null, TextInputType.text, 24, Colors.orange,
                      (title) {
                    this.title = title;
                  }, _titleFormKey, title, null),
                  SizedBox(height: 40),
                  buildTimeSection(),
                  const SizedBox(height: 40),
                  _buildSectionTitle("INFORMATION"),
                  buildListedView(context),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle("ANTECKNINGAR"),
                  _buildNotesTextField(),
                  _buildActionButtons(),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
          _buildPhotoButtons()
        ],
      ),
    );
  }

  Column buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("TID"),
        Container(height: 0.5, color: Colors.grey.shade400),
        //SizedBox(height: 10),
        StartEndDateSelector(
            startDateSelectorController: startDateController,
            endDateSelectorController: endDateController,
            onChangeStart: (te) {
              setState(() {});
            },
            onChangeEnd: (te) {
              setState(() {});
            },
            color: Colors.transparent),
        Container(height: 0.5, color: Colors.grey.shade400),
      ],
    );
  }

  ListedView buildListedView(BuildContext context) {
    return ListedView(
        hidesFirstLastSeparator: false,
        rowInset: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        items: [
          ListedItem(
              leadingIcon: Icons.group,
              child: Text("Välj personer"),
              trailingWidget: Row(
                children: [
                  buildSelectedPersonsAvatars(),
                  Icon(Icons.chevron_right)
                ],
              ),
              onTap: () {
                pushNewScreen(context,
                    screen: PersonSelectScreen(
                      persons: widget.persons,
                      personCallback: this.selectPersons,
                      preSelectedPersons: selectedPersons,
                    ));
              }),
          ListedItem(
              leadingIcon: Icons.person,
              child: Text("Välj kund"),
              trailingWidget: Row(
                children: [
                  Text(selectedCustomer?.name ?? ""),
                  selectedCustomer != null
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              this.selectedCustomer = null;
                            });
                          },
                          child: Icon(Icons.clear))
                      : Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                print("Tapped");
                pushNewScreen(context, screen: CustomerSelectScreen(
                  didSelectCustomer: (customer, contact) {
                    setState(() {
                      selectedCustomerContactPerson = contact;
                      selectedCustomer = customer;
                      locationController.text = customer.address ?? "";
                      phonenumberController.text =
                          customer.contacts[contact].phoneNumber;
                      companyController.text = customer.name;
                    });
                  },
                ));
              }),
          ListedTextField(
              leadingIcon: Icons.business_center,
              placeholder: "Kund fritext",
              onChanged: (customer) {
                this.customer = customer;
              },
              key: _companyFormKey,
              controller: companyController),
          ListedTextField(
              leadingIcon: Icons.location_on,
              placeholder: "Address",
              onChanged: (location) {
                this.location = location;
              },
              key: _locationFormKey,
              controller: locationController),
          ListedTextField(
              leadingIcon: Icons.phone,
              placeholder: "Telefonnummer",
              onChanged: (number) {
                this.phoneNumber = number;
              },
              key: _phoneNumberFormKey,
              controller: phonenumberController),
          ListedItem(
              leadingIcon: Icons.image_rounded,
              child: Text("Lägg till bilder"),
              trailingWidget: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [selectedImagesPreview(), Icon(Icons.chevron_right)],
              ),
              onTap: () {
                setState(() {
                  isSelectingPhotoProvider = !isSelectingPhotoProvider;
                });
              }),
        ]);
  }

  ListPersonCircleAvatar buildSelectedPersonsAvatars() {
    return ListPersonCircleAvatar(persons: this.selectedPersons);
  }

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(source: imageSource);

    setState(() {
      if (pickedFile != null) {
        print("Picked Image");
        _image = File(pickedFile.path);
        selectedImages.add(_image!);
      } else {
        print('No image selected.');
      }
      isSelectingPhotoProvider = false;
    });
  }

  Widget _buildPhotoButtons() {
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
              setState(() => this.isSelectingPhotoProvider = false);
            }, "Avbryt"),
          ],
        ));
  }

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

  Widget selectedImagesPreview() {
    return Row(
        children: List.generate(selectedImages.length, (index) {
      var image = selectedImages[index];
      return Row(
        children: [
          SizedBox(
              width: 50,
              height: 50,
              child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ImageDialog(
                            image: Image.file(image, fit: BoxFit.cover)));
                  },
                  child: Image.file(image)))
        ],
      );
    }));
  }

  // Widget _selectedImagesPreview() {
  //   return ListView.separated(
  //       physics: const NeverScrollableScrollPhysics(),
  //       scrollDirection: Axis.horizontal,
  //       itemCount: selectedImages.length,
  //       shrinkWrap: true,
  //       itemBuilder: (context, index) {
  //         var image = selectedImages[index];
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 0.0),
  //           child: GestureDetector(
  //             onTap: () {
  //               showDialog(
  //                   context: context,
  //                   builder: (_) => ImageDialog(image: Image.file(image)));
  //             },
  //             child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(6),
  //                 child: Image.file(image, width: 30, fit: BoxFit.fitHeight)),
  //           ),
  //         );
  //       },
  //       separatorBuilder: (context, index) {
  //         return SizedBox(width: 5.0);
  //       });
  // }

  // ListTile selectEnd(BuildContext context) {
  //   return ListTile(
  //       title: Text("Slutar", style: TextStyle(fontSize: fontSize)),
  //       leading: Icon(Icons.access_time),
  //       trailing: Text(dateStringVerbose(endDate),
  //           style: TextStyle(fontSize: fontSize)),
  //       contentPadding: contentPadding,
  //       key: _endTimeFormKey,
  //       onTap: () {
  //         DatePicker.showDateTimePicker(
  //           context,
  //           showTitleActions: true,
  //           minTime: DateTime.now().subtract(
  //             Duration(days: 20),
  //           ),
  //           maxTime: DateTime.now().add(
  //             Duration(days: 150),
  //           ),
  //           onChanged: (date) {
  //             setState(() {
  //               endDate = date;
  //               if (startDate.isAfter(endDate)) {
  //                 startDate = DateTime(endDate.year, endDate.month, endDate.day,
  //                     startDate.hour, startDate.minute);
  //               }
  //             });
  //           },
  //           locale: LocaleType.sv,
  //           currentTime: endDate,
  //         );
  //       });
  // }

  // ListTile selectStart(BuildContext context) {
  //   return ListTile(
  //       title: Text("Startar", style: TextStyle(fontSize: fontSize)),
  //       leading: Icon(Icons.access_time),
  //       trailing: Text(dateStringVerbose(startDate),
  //           style: TextStyle(fontSize: fontSize)),
  //       contentPadding: contentPadding,
  //       key: _startTimeFormKey,
  //       onTap: () {
  //         DatePicker.showDateTimePicker(
  //           context,
  //           showTitleActions: true,
  //           minTime: DateTime.now().subtract(
  //             Duration(days: 20),
  //           ),
  //           maxTime: DateTime.now().add(
  //             Duration(days: 150),
  //           ),
  //           onChanged: (date) {
  //             setState(() {
  //               startDate = date;
  //               if (startDate.isAfter(endDate)) {
  //                 endDate = DateTime(startDate.year, startDate.month,
  //                     startDate.day, endDate.hour, endDate.minute);
  //               }
  //             });
  //           },
  //           locale: LocaleType.sv,
  //           currentTime: startDate,
  //         );
  //       });
  // }
}

class UnResizableContainer extends StatelessWidget {
  final Widget child;
  UnResizableContainer({required this.child});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(child: child),
      ),
    );
  }
}
