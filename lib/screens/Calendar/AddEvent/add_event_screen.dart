import 'dart:io';

import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/screens/Calendar/AddEvent/contact_person_select_screen.dart';
import 'package:zimple/screens/Calendar/AddEvent/customer_select_screen.dart';
import 'package:zimple/screens/Calendar/AddEvent/person_select_screen.dart';
import 'package:zimple/screens/Calendar/AddEvent/work_category_select.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/start_end_date_selector.dart';
import 'package:zimple/widgets/widgets.dart';

class AddEventScreen extends StatefulWidget {
  static const String routeName = 'add_event_screen';
  final List<Person> persons;
  final FirebaseEventManager firebaseEventManager;
  final FirebaseStorageManager firebaseStorageManager;
  final Event? eventToChange;
  AddEventScreen(
      {required this.persons, required this.firebaseEventManager, required this.firebaseStorageManager, this.eventToChange});
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late DateTime startDate;
  late DateTime endDate;
  EdgeInsets contentPadding = EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0);
  List<Person> selectedPersons = [];
  String title = "";
  String? phoneNumber;
  String? notes;
  String? customer;
  String? location;
  Customer? selectedCustomer;
  int? selectedCustomerContactPerson;
  WorkCategory? selectedWorkCategory;
  Contact? selectedContactPerson;

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

  static const fontSize = 16.0;

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
      if (widget.eventToChange?.workCategoryId != null && widget.eventToChange != null) {
        selectedWorkCategory = WorkCategory(widget.eventToChange!.workCategoryId!);
      }
      if (widget.eventToChange?.contactKey != null) {
        selectedContactPerson =
            context.read<ManagerProvider>().contacts.firstWhereOrNull((c) => c.id == widget.eventToChange?.contactKey);
      }

      List<Customer> customers = Provider.of<ManagerProvider>(context, listen: false).customers;
      if (widget.eventToChange?.customerKey != null && widget.eventToChange?.customerKey != "") {
        selectedCustomer = customers.firstWhereOrNull((c) => c.id == widget.eventToChange?.customerKey);
        selectedCustomerContactPerson = widget.eventToChange?.customerContactIndex ?? 0;
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

  Widget _buildTextField(String hintText, Widget? leading, TextInputType inputType, double fontSize, Color focusColor,
      Function(String) onChanged, GlobalKey<FormState> key, String initialValue, TextEditingController? controller) {
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
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
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
        customerContactIndex: this.selectedCustomerContactPerson,
        workCategoryId: selectedWorkCategory?.id,
        contactKey: selectedContactPerson?.id);
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
                  borderSide: BorderSide(width: 0.3, color: Theme.of(context).dividerColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.zero),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.3, color: Theme.of(context).dividerColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.zero),
              border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.3, color: Theme.of(context).dividerColor.withOpacity(0.3)),
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
      child: ListedTitle(title: title),
    );
  }

  Event? _uploadEventImages(String? key) {
    if (key == null) return null;
    List<String> fileUids = selectedImages.map((_) => Uuid().v4().toString()).toList();
    Map<String, Map<String, String>> map = {};
    fileUids.forEach((fileName) {
      Map<String, String> innerMap = {'storagePath': "/Events/$key/$fileName"};
      var uuid = Uuid().v4().toString();
      map[uuid] = innerMap;
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
    Event? event = _uploadEventImages(ref.key);
    if (event == null) return;
    print("Adding new event");
    context.loaderOverlay.show();
    widget.firebaseEventManager.addEventWithRef(ref, event).then((value) {
      context.loaderOverlay.hide();
      Navigator.pop(context);
    });
  }

  void _changeEvent() async {
    print("Changing event with id: ${widget.eventToChange?.id}");
    Event? event = _uploadEventImages(widget.eventToChange!.id);
    if (event == null) return;
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
                text: "Spara",
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          PreferredSize(preferredSize: appBarSize, child: StandardAppBar(changingEvent ? "Ändra arbetsorder" : "Ny arbetsorder")),
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
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Titel", null, TextInputType.text, 24, Colors.orange, (title) {
                        this.title = title;
                      }, _titleFormKey, title, null),
                      SizedBox(height: 32),
                      buildTimeSection(),
                      const SizedBox(height: 32),
                      _buildSectionTitle("INFORMATION"),
                      buildListedView(context),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(height: 20),
                      _buildSectionTitle("ANTECKNINGAR"),
                      _buildNotesTextField(),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: _buildActionButtons(),
                )
              ],
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
        Container(height: 0.3, color: Theme.of(context).dividerColor.withOpacity(0.3)),
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
        Container(height: 0.3, color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ],
    );
  }

  ListedView buildListedView(BuildContext context) {
    return ListedView(hidesFirstLastSeparator: false, rowInset: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0), items: [
      ListedItem(
        leadingIcon: FeatherIcons.userPlus,
        text: "Personer",
        trailingWidget: Row(
          children: [
            buildSelectedPersonsAvatars(),
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _onTapAddPersons(context),
      ),
      ListedItem(
          leadingIcon: FeatherIcons.briefcase,
          text: "Kund",
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
          onTap: () => _onTapAddCustomer(context)),
      _buildTypeOfWorkRow(),
      _buildContactPersonRow(),
      ListedTextField(
          leadingIcon: FeatherIcons.briefcase,
          placeholder: "Kund fritext",
          onChanged: (customer) => this.customer = customer,
          key: _companyFormKey,
          controller: companyController),
      ListedTextField(
          leadingIcon: FeatherIcons.mapPin,
          placeholder: "Address",
          onChanged: (location) => this.location = location,
          key: _locationFormKey,
          controller: locationController),
      // ListedTextField(
      //     leadingIcon: Icons.phone,
      //     placeholder: "Telefonnummer",
      //     onChanged: (number) => this.phoneNumber = number,
      //     key: _phoneNumberFormKey,
      //     controller: phonenumberController),
      ListedItem(
          leadingIcon: FeatherIcons.image,
          text: "Lägg till bilder",
          trailingWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              selectedImagesPreview(),
              Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => setState(() {
                isSelectingPhotoProvider = !isSelectingPhotoProvider;
              })),
    ]);
  }

  Future<dynamic> _onTapAddCustomer(BuildContext context) {
    return PersistentNavBarNavigator.pushNewScreen(context, screen: CustomerSelectScreen(
      didSelectCustomer: (customer, contact) {
        setState(() {
          selectedCustomerContactPerson = contact;
          selectedCustomer = customer;
          locationController.text = customer.address ?? "";
          phonenumberController.text = customer.contacts[contact].phoneNumber;
          companyController.text = customer.name;
        });
      },
    ));
  }

  Future<dynamic> _onTapAddPersons(BuildContext context) {
    return PersistentNavBarNavigator.pushNewScreen(context,
        screen: PersonSelectScreen(
          persons: widget.persons,
          personCallback: this.selectPersons,
          preSelectedPersons: selectedPersons,
        ));
  }

  ListPersonCircleAvatar buildSelectedPersonsAvatars() => ListPersonCircleAvatar(
        widthMultiplier: 0.5,
        persons: this.selectedPersons,
        alignment: WrapAlignment.end,
      );

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource);

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
    return PhotoButtons(
        isSelectingPhotoProvider: this.isSelectingPhotoProvider,
        didTapCancel: () {
          setState(() {
            this.isSelectingPhotoProvider = false;
          });
        },
        didReceiveImage: (image) {
          setState(() {
            if (image != null) {
              print("Picked Image");
              _image = File(image.path);
              selectedImages.add(_image!);
            } else {
              print('No image selected.');
            }
            isSelectingPhotoProvider = false;
          });
        });
  }

  ListedItem _buildContactPersonRow() => ListedItem(
        leadingIcon: Icons.contact_phone,
        text: "Kontaktperson",
        trailingWidget: Row(
          children: [
            Text(selectedContactPerson?.name ?? ""),
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ContactPersonSelectScreen(didSelectContact: (contact) => setState(() => this.selectedContactPerson = contact)),
        ),
      );

  ListedItem _buildTypeOfWorkRow() => ListedItem(
      leadingIcon: Icons.widgets,
      text: "Kategori",
      trailingWidget: Row(
        children: [
          _buildSelectedTypeOfWork(),
          Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(context,
            screen: WorkCategorySelectScreen(
                onSelectWorkCategory: (category) => setState(() => this.selectedWorkCategory = category)));
      });

  Widget _buildSelectedTypeOfWork() => selectedWorkCategory == null
      ? Container()
      : Row(
          children: [
            //Icon(Linecons.globe),
            Icon(selectedWorkCategory!.icon, size: 20),
            SizedBox(width: 12),
            Text(selectedWorkCategory!.name),
          ],
        );

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
                    showDialog(context: context, builder: (_) => ImageDialog(image: Image.file(image, fit: BoxFit.cover)));
                  },
                  child: Image.file(image)))
        ],
      );
    }));
  }
}

class ListedTitle extends StatelessWidget {
  final String title;
  const ListedTitle({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w900, letterSpacing: 0.5));
  }
}
