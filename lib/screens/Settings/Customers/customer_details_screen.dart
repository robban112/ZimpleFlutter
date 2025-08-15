import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/screens/Settings/Customers/add_customer_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/button/nav_bar_back.dart';
import 'package:zimple/widgets/provider_widget.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({Key? key, required this.customer}) : super(key: key);

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late FirebaseCustomerManager firebaseCustomerManager;

  void onDelete() {
    context.loaderOverlay.show();
    firebaseCustomerManager.deleteCustomer(widget.customer).then((value) {
      context.loaderOverlay.hide();
      Future.delayed(Duration(milliseconds: 500)).then((value) => Navigator.of(context).pop());
    });
  }

  void deleteCustomer() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text("Ta bort kund"),
              content: new Text("Är du säker på att du vill ta bort den här kunden?"),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text("Ja"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    }),
                CupertinoDialogAction(
                  child: Text("Nej"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    Customer customer = widget.customer;
    firebaseCustomerManager = Provider.of<ManagerProvider>(context, listen: true).firebaseCustomerManager;
    double width = MediaQuery.of(context).size.width;
    double rowHeight = 40;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        leading: NavBarBack(),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteCustomer,
          ),
          IconButton(
            splashRadius: 5,
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: AddCustomerScreen(
                    customerToChange: customer,
                  ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(height: 6.0),
                Text(customer.name, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.0),
                Row(children: [
                  Icon(Icons.location_city),
                  SizedBox(width: 12.0),
                  Text(customer.address ?? "", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400)),
                ]),
                SizedBox(height: 12.0),
                customer.orgNr != ""
                    ? Row(
                        children: [Text("Org. Nr: "), Text(customer.orgNr ?? "")],
                      )
                    : Container()
              ]),
              SizedBox(height: 24.0),
              Text("Kontakter", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400)),
              Table(
                  columnWidths: const <int, TableColumnWidth>{0: FlexColumnWidth(), 1: FlexColumnWidth(), 2: FlexColumnWidth()},
                  children: [
                        TableRow(children: [
                          Container(
                            height: rowHeight,
                            child: Row(
                              children: [
                                Text("Namn", style: greyText),
                                SizedBox(width: 16.0),
                              ],
                            ),
                          ),
                          Container(
                            height: rowHeight,
                            child: Row(
                              children: [
                                Text("Email", style: greyText),
                                SizedBox(width: 16.0),
                              ],
                            ),
                          ),
                          Container(
                            height: rowHeight,
                            child: Row(
                              children: [
                                Text("Telefonnummer", style: greyText.copyWith(fontSize: 13)),
                                SizedBox(width: 16.0),
                              ],
                            ),
                          )
                        ]),
                      ] +
                      List.generate(customer.contacts.length, (index) {
                        var contact = customer.contacts[index];
                        return TableRow(children: [
                          TableCell(child: Container(height: rowHeight, child: Text(contact.name))),
                          TableCell(
                              child: RichText(
                            text: TextSpan(
                                text: contact.email,
                                style: TextStyle(color: Colors.lightBlue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _makeEmail(contact.email ?? "");
                                  }),
                          )),
                          TableCell(
                              child: RichText(
                                  text: TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _makePhoneCall('tel:${contact.phoneNumber}');
                                        },
                                      text: contact.phoneNumber,
                                      style: TextStyle(color: Colors.lightBlue))))
                        ]);
                      }))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makeEmail(String email) async {
    var url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
