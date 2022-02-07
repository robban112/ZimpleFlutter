import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rounded_button.dart';

class AddCustomerScreen extends StatefulWidget {
  AddCustomerScreen({this.customerToChange});
  final Customer? customerToChange;
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  List<Contact> contacts = [];
  late FirebaseCustomerManager firebaseCustomerManager;
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController orgNrController = TextEditingController();
  String? name;
  String? address;
  String? orgNr;

  late bool isChangingCustomer;

  @override
  void initState() {
    super.initState();
    print("Init State Add Customer Screen");
    this.isChangingCustomer = widget.customerToChange != null;
    if (isChangingCustomer) initChangeCustomerFields();
    firebaseCustomerManager = Provider.of<ManagerProvider>(context, listen: false).firebaseCustomerManager;
  }

  void initChangeCustomerFields() {
    Customer customer = widget.customerToChange!;
    nameController.text = customer.name;
    addressController.text = customer.address ?? "";
    orgNrController.text = customer.orgNr ?? "";
    contacts = List.from(customer.contacts);
  }

  void updateCustomer() {
    print("Update customer");
    Customer updateCustomer = widget.customerToChange!;
    updateCustomer.name = nameController.text;
    updateCustomer.address = addressController.text;
    updateCustomer.orgNr = orgNrController.text;
    updateCustomer.contacts = contacts;
    firebaseCustomerManager.changeCustomer(updateCustomer).then((value) => Navigator.pop(context));
  }

  void addNewCustomer() {
    if (name == null) {
      print("name is null");
      return;
    }
    var customer = Customer(name!, address ?? "", orgNr ?? "", contacts);
    firebaseCustomerManager.addCustomer(customer).then((value) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    print("Building Add Customer Screen");
    return Scaffold(
        appBar: PreferredSize(preferredSize: appBarSize, child: StandardAppBar("Lägg till kund")),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    _buildContactsSection(),
                  ],
                ),
              ),
            ),
            SaveCancelActionButtons(
              context: context,
              didTapSave: () {
                // setup handle if name address is null
                if (isChangingCustomer)
                  updateCustomer();
                else
                  addNewCustomer();
              },
            ),
          ],
        ));
  }

  Column _buildContactsSection() {
    return Column(
      children: [
        SizedBox(height: 20.0),
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
                contacts.add(Contact("", "", "", ""));
              });
            },
          ),
        ),
        SizedBox(height: 100),
      ],
    );
  }

  Column _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListedTitle(text: "Företag"),
        SizedBox(height: 5.0),
        ListedView(hidesFirstLastSeparator: false, items: [
          ListedTextField(
              leadingIcon: Icons.short_text,
              placeholder: 'Namn',
              controller: nameController,
              onChanged: (name) {
                this.name = name;
              }),
          ListedTextField(
              leadingIcon: Icons.location_city,
              placeholder: 'Address',
              controller: addressController,
              onChanged: (location) {
                this.address = location;
              }),
          ListedTextField(
              leadingIcon: Icons.short_text,
              placeholder: 'Org Nr',
              controller: orgNrController,
              onChanged: (orgNr) {
                this.orgNr = orgNr;
              })
        ]),
      ],
    );
  }

  Widget buildContactList() {
    return Column(
      children: List.generate(contacts.length, (index) {
        Contact contact = contacts[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListedTitle(text: "Kontakt ${index + 1}"),
            ListedView(hidesFirstLastSeparator: false, items: [
              ListedTextField(
                  leadingIcon: Icons.short_text,
                  placeholder: 'Namn',
                  controller: TextEditingController(text: contact.name),
                  onChanged: (name) {
                    contact.name = name;
                  }),
              ListedTextField(
                  leadingIcon: Icons.phone,
                  placeholder: 'Telefonnummer',
                  controller: TextEditingController(text: contact.phoneNumber),
                  inputType: TextInputType.number,
                  onChanged: (number) {
                    contact.phoneNumber = number;
                  }),
              ListedTextField(
                  leadingIcon: Icons.email,
                  placeholder: 'Email',
                  controller: TextEditingController(text: contact.email),
                  onChanged: (email) {
                    contact.email = email;
                  })
            ]),
            SizedBox(height: 24.0),
          ],
        );
      }),
    );
  }
}

class SaveCancelActionButtons extends StatelessWidget {
  const SaveCancelActionButtons({Key? key, required this.context, required this.didTapSave}) : super(key: key);

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
                color: Theme.of(context).colorScheme.secondary,
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
