import 'package:zimple/model/event.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/screens/Calendar/person_select_screen.dart';
import 'package:zimple/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../../utils/date_utils.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AddEventScreen extends StatefulWidget {
  static const String routeName = 'add_event_screen';
  final List<Person> persons;
  final FirebaseEventManager firebaseEventManager;
  final Event eventToChange;
  AddEventScreen(
      {@required this.persons,
      @required this.firebaseEventManager,
      this.eventToChange});
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  DateTime startDate;
  DateTime endDate;
  EdgeInsets contentPadding =
      EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0);
  List<Person> selectedPersons = [];
  String title;
  String phoneNumber;
  String notes;
  String customer;
  String location;

  bool changingEvent;
  bool isSelectingPhotoProvider = false;

  final GlobalKey<FormState> _titleFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _startTimeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _endTimeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _personsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _companyFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _phoneNumberFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _notesFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _imagesFormKey = GlobalKey<FormState>();

  static const orange = Color(0xffFF9800);
  static const fontSize = 14.0;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    changingEvent = widget.eventToChange != null;
    if (changingEvent) {
      startDate = widget.eventToChange?.start;
      endDate = widget.eventToChange?.end;
      title = widget.eventToChange?.title;
      phoneNumber = widget.eventToChange?.phoneNumber;
      notes = widget.eventToChange?.notes;
      customer = widget.eventToChange?.customer;
      location = widget.eventToChange?.location;
      selectedPersons = widget.eventToChange?.persons;
    } else {
      startDate = new DateTime(now.year, now.month, now.day, 8, 0, 0);
      endDate = new DateTime(now.year, now.month, now.day, 16, 0, 0);
    }
  }

  void selectPersons(List<Person> persons) {
    setState(() {
      selectedPersons = persons;
    });
  }

  Widget _buildTextField(
      String hintText,
      Widget leading,
      TextInputType inputType,
      double fontSize,
      Color focusColor,
      Function(String) onChanged,
      GlobalKey<FormState> key,
      String initialValue) {
    return ListTile(
      leading: leading,
      title: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.done,
              initialValue: initialValue,
              key: key,
              style: TextStyle(fontSize: fontSize),
              autocorrect: false,
              keyboardType: inputType,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: fontSize),
                focusColor: focusColor,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue),
                ),
              ),
              // your TextField's Content
            ),
          ),
        ],
      ),
      contentPadding: contentPadding,
    );
  }

  Event _getNewEvent() {
    return Event(
        id: widget.eventToChange?.id,
        title: this.title,
        start: this.startDate,
        end: this.endDate,
        persons: this.selectedPersons,
        phoneNumber: this.phoneNumber,
        notes: this.notes,
        location: this.location,
        customer: this.customer);
  }

  Widget _buildDivider([double thickness]) {
    thickness ??= 0.5;
    return Divider(height: 20, thickness: thickness, color: Colors.grey);
  }

  Widget _buildNotesTextField() {
    return ListTile(
      leading: Icon(Icons.note),
      title: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              key: _notesFormKey,
              textInputAction: TextInputAction.done,
              minLines: 10,
              maxLines: 15,
              keyboardType: TextInputType.multiline,
              onChanged: (notes) {
                this.notes = notes;
              },
              initialValue: this.notes,
              decoration: InputDecoration(
                  hintText: 'Anteckningar',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  focusColor: Colors.lightBlue),
            ),
          ),
        ],
      ),
      contentPadding: contentPadding,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 8.0),
      child: Text(title, style: TextStyle(color: Colors.grey.shade700)),
    );
  }

  String _textSelectedPersons() {
    var length = selectedPersons.length;
    if (length > 3) {
      return "$length personer";
    } else {
      var concatenate = StringBuffer();
      selectedPersons.forEach((person) {
        concatenate.write(person.name + ", ");
      });
      return concatenate.toString();
    }
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 18.0),
        child: Row(
          children: [
            Expanded(
              child: RoundedButton(
                text: "Avbryt",
                color: Colors.white,
                onTap: () {
                  Navigator.pop(context);
                },
                textColor: Colors.black,
                fontSize: 17.0,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: RoundedButton(
                text: "Spara",
                color: Colors.lightBlue,
                onTap: () {
                  context.showLoaderOverlay();
                  if (changingEvent) {
                    print("Changing event with id: ${widget.eventToChange.id}");
                    widget.firebaseEventManager
                        .changeEvent(_getNewEvent())
                        .then((value) {
                      context.hideLoaderOverlay();
                      Navigator.pop(context);
                    });
                  } else {
                    print("Adding new event");
                    widget.firebaseEventManager
                        .addEvent(_getNewEvent())
                        .then((value) {
                      context.hideLoaderOverlay();
                      Navigator.pop(context);
                    });
                  }
                },
                textColor: Colors.white,
                fontSize: 17.0,
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        backgroundColor: Colors.blueGrey,
        title: Text("Nytt event"),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 12),
            physics: BouncingScrollPhysics(),
            children: [
              _buildTextField(
                  "Titel", null, TextInputType.text, 24, Colors.orange,
                  (title) {
                this.title = title;
              }, _titleFormKey, title),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("TID"),
                    selectStart(context),
                    selectEnd(context),
                  ],
                ),
              ),
              //_buildDivider(0.5),
              SizedBox(height: 20),
              _buildSectionTitle("INFORMATION"),
              _buildPersonsListTile(context),
              _buildSelectImagesListTile(context),
              _buildTextField("Företag", Icon(Icons.business_center),
                  TextInputType.text, fontSize, orange, (customer) {
                this.customer = customer;
              }, _companyFormKey, customer),
              _buildTextField("Address", Icon(Icons.location_city),
                  TextInputType.text, fontSize, orange, (location) {
                this.location = location;
              }, _locationFormKey, location),
              _buildTextField("Telefonnummer", Icon(Icons.phone),
                  TextInputType.phone, fontSize, orange, (phoneNumber) {
                this.phoneNumber = phoneNumber;
              }, _phoneNumberFormKey, phoneNumber),

              const SizedBox(
                height: 10,
              ),
              SizedBox(height: 20),
              _buildSectionTitle("ANTECKNINGAR"),
              const SizedBox(
                height: 10,
              ),
              _buildNotesTextField(),
              const SizedBox(height: 150),
            ],
          ),
          _buildActionButtons(),
          _buildPhotoButtons()
        ],
      ),
    );
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
            _buildPhotoButton(() {}, "Ta foto"),
            SizedBox(height: 1.0),
            _buildPhotoButton(() {}, "Välj foto"),
            SizedBox(height: 5.0),
            _buildPhotoButton(() {
              setState(
                () {
                  isSelectingPhotoProvider = false;
                },
              );
            }, "Avbryt"),
          ],
        ));
  }

  Widget _buildPhotoButton(Function onTap, String text) {
    return Container(
      height: 75.0,
      width: 120,
      child: ButtonTheme(
        height: 60.0,
        child: ElevatedButton(
          child: Text(text, style: TextStyle(fontSize: 20.0)),
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

  ListTile _buildSelectImagesListTile(BuildContext context) {
    return ListTile(
        key: _imagesFormKey,
        title: Text(
          "Bilder",
          style: TextStyle(fontSize: fontSize),
        ),
        leading: Icon(Icons.image_rounded),
        contentPadding: contentPadding,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(
                  _textSelectedPersons(),
                  overflow: TextOverflow.clip,
                )),
            Icon(Icons.chevron_right)
          ],
        ),
        onTap: () {
          setState(() {
            isSelectingPhotoProvider = !isSelectingPhotoProvider;
          });
        });
  }

  ListTile _buildPersonsListTile(BuildContext context) {
    return ListTile(
        key: _personsFormKey,
        title: Text("Välj personer", style: TextStyle(fontSize: fontSize)),
        leading: Icon(Icons.person),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 100),
                child: Text(
                  _textSelectedPersons(),
                  overflow: TextOverflow.clip,
                )),
            Icon(Icons.chevron_right)
          ],
        ),
        contentPadding: contentPadding,
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PersonSelectScreen(
                        persons: widget.persons,
                        personCallback: this.selectPersons,
                        preSelectedPersons: selectedPersons,
                      )));
        });
  }

  ListTile selectEnd(BuildContext context) {
    return ListTile(
        title: Text("Slutar", style: TextStyle(fontSize: fontSize)),
        leading: Icon(Icons.access_time),
        trailing: Text(dateStringVerbose(endDate),
            style: TextStyle(fontSize: fontSize)),
        contentPadding: contentPadding,
        key: _endTimeFormKey,
        onTap: () {
          DatePicker.showDateTimePicker(
            context,
            showTitleActions: true,
            minTime: DateTime.now().subtract(
              Duration(days: 20),
            ),
            maxTime: DateTime.now().add(
              Duration(days: 150),
            ),
            onChanged: (date) {
              setState(() {
                endDate = date;
              });
            },
            locale: LocaleType.sv,
            currentTime: endDate,
          );
        });
  }

  ListTile selectStart(BuildContext context) {
    return ListTile(
        title: Text("Startar", style: TextStyle(fontSize: fontSize)),
        leading: Icon(Icons.access_time),
        trailing: Text(dateStringVerbose(startDate),
            style: TextStyle(fontSize: fontSize)),
        contentPadding: contentPadding,
        key: _startTimeFormKey,
        onTap: () {
          DatePicker.showDateTimePicker(
            context,
            showTitleActions: true,
            minTime: DateTime.now().subtract(
              Duration(days: 20),
            ),
            maxTime: DateTime.now().add(
              Duration(days: 150),
            ),
            onChanged: (date) {
              setState(() {
                startDate = date;
              });
            },
            locale: LocaleType.sv,
            currentTime: startDate,
          );
        });
  }
}
