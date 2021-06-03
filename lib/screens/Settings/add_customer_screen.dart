import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rounded_button.dart';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  List<Contact> contacts = [];
  FirebaseCustomerManager firebaseCustomerManager;
  String name;
  String address;

  @override
  void initState() {
    super.initState();
    firebaseCustomerManager =
        Provider.of<ManagerProvider>(context, listen: false)
            .firebaseCustomerManager;
  }

  Widget _buildTextField(
    String hintText,
    TextInputType inputType,
    Function(String) onChanged,
    GlobalKey<FormState> key,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(-2, 2), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextFormField(
            textInputAction: TextInputAction.done,
            key: key,
            style: TextStyle(fontSize: 14),
            autocorrect: false,
            keyboardType: inputType,
            onChanged: onChanged,
            decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 14),
                focusColor: primaryColor,
                focusedBorder: InputBorder.none,
                border: InputBorder.none),
            // your TextField's Content
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm(int index) {
    return Column(
      children: [
        _buildTextField("Namn", TextInputType.name, (value) {
          contacts[index].name = value;
        }, null),
        _buildTextField("Telefonnummer", TextInputType.phone, (value) {
          contacts[index].phoneNumber = value;
        }, null),
        _buildTextField("Email", TextInputType.emailAddress, (value) {
          contacts[index].email = value;
        }, null),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lägg till kund"),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Företag", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 5.0),
                    _buildTextField("Namn", TextInputType.name, (value) {
                      this.name = value;
                    }, null),
                    _buildTextField("Address", TextInputType.name, (value) {
                      this.address = value;
                    }, null),
                    SizedBox(height: 20.0),
                    Text("Kontakter", style: TextStyle(fontSize: 18)),
                    contacts != [] ? buildContactList() : Container(),
                    SizedBox(height: 16.0),
                    Center(
                      child: RoundedButton(
                        text: "Lägg till kontakt",
                        color: Colors.white,
                        textColor: Colors.black,
                        fontSize: 14.0,
                        onTap: () {
                          setState(() {
                            contacts.add(Contact("", "", ""));
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 100)
                  ],
                ),
              ),
            ),
            SaveCancelActionButtons(
              context: context,
              didTapSave: () {
                var customer = Customer(name, address, contacts);
                firebaseCustomerManager.addCustomer(customer);
              },
            ),
          ],
        ));
  }

  ListView buildContactList() {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text("Kontakt ${index + 1}"),
              _buildContactForm(index),
              SizedBox(height: 10),
            ],
          );
        });
  }
}

class SaveCancelActionButtons extends StatelessWidget {
  const SaveCancelActionButtons(
      {Key key, @required this.context, this.didTapSave})
      : super(key: key);

  final BuildContext context;
  final Function didTapSave;

  @override
  Widget build(BuildContext context) {
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
                  didTapSave();
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
}
