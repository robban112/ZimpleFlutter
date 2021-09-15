import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/screens/Settings/Customers/customer_details_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view.dart';
import 'package:zimple/widgets/provider_widget.dart';

import 'add_customer_screen.dart';

class CustomerPanel {
  Customer customer;
  bool isExpanded;
  CustomerPanel(this.customer, this.isExpanded);
}

class CustomerScreen extends StatefulWidget {
  static const String routeName = "customer_screen";
  final List<Customer> customers;

  CustomerScreen({required this.customers});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<CustomerPanel> customerPanels = [];

  double kPadding = 20.0;

  _CustomerScreenState();

  @override
  void initState() {
    this.customerPanels =
        widget.customers.map((e) => CustomerPanel(e, false)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Building Customer Screen");
    var customers =
        Provider.of<ManagerProvider>(context, listen: true).customers;
    var user = Provider.of<ManagerProvider>(context, listen: false).user;
    return FocusDetector(
      onFocusGained: () {
        setState(() {});
      },
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: StandardAppBar("Kundbas")),
        floatingActionButton: user.isAdmin
            ? FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                backgroundColor: green,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCustomerScreen(),
                      ));
                },
              )
            : Container(),
        body: SingleChildScrollView(
          child: ListedView(
              items: List.generate(customers.length, (index) {
            Customer customer = customers[index];
            return ListedItem(
                trailingIcon: Icons.chevron_right,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name),
                    Text(customer.address ?? "",
                        style: TextStyle(
                            fontSize: 14.0, color: Colors.grey.shade600))
                  ],
                ),
                onTap: () {
                  pushNewScreen(context,
                      screen: CustomerDetailsScreen(customer: customer));
                });
          })),
          // child: Column(
          //   children: [
          //     TopHeader(kPadding: kPadding),
          //     Padding(
          //       padding: EdgeInsets.symmetric(
          //           vertical: kPadding, horizontal: kPadding),
          //       child: Container(),
          //     ),
          //     ExpansionPanelList(
          //       expansionCallback: (int index, bool isExpanded) {
          //         setState(() {
          //           customerPanels[index].isExpanded = !isExpanded;
          //         });
          //       },
          //       children: customerPanels.asMap().entries.map((entry) {
          //         int index = entry.key;
          //         var panel = entry.value;
          //         var customer = panel.customer;
          //         return ExpansionPanel(
          //             isExpanded: panel.isExpanded,
          //             headerBuilder: (BuildContext context, bool isExpanded) {
          //               return expandableHeader(index, isExpanded, customer);
          //             },
          //             body: expandableBody(customer));
          //       }).toList(),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  Widget expandableHeader(int index, bool isExpanded, Customer customer) {
    return Theme(
      data: ThemeData(
          splashColor: Colors.transparent, highlightColor: Colors.transparent),
      child: ListTile(
        onTap: () {
          setState(() {
            customerPanels[index].isExpanded = !isExpanded;
          });
        },
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.name),
              Text(customer.address ?? "",
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600))
            ],
          ),
        ),
      ),
    );
  }

  ListView expandableBody(Customer customer) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: customer.contacts.length + 1,
        itemBuilder: (context, index) {
          if (index == customer.contacts.length) {
            return Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: Text("Ändra"),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: Text("Ta bort"),
                    onPressed: () {},
                  ),
                ),
              ],
            );
          }
          var contact = customer.contacts[index];
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text(contact.email),
                    SizedBox(height: 2),
                    Text(contact.phoneNumber)
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({
    Key? key,
    required this.kPadding,
  }) : super(key: key);

  final double kPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0))),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Kunder",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 21.0,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
                child: Text(
                  "Här kan du enkelt lägga till ditt företags kunder och kontaktpersoner. " +
                      "\nLägg sedan till dom enkelt i planeringen.",
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w100),
                ),
              )
            ],
          ),
        ));
  }
}
