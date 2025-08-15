import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:zimple/screens/Calendar/AddEvent/customer_select_screen.dart';
import 'package:zimple/screens/Settings/Customers/customer_details_screen.dart';
import 'package:zimple/utils/generic_imports.dart';

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
    this.customerPanels = widget.customers.map((e) => CustomerPanel(e, false)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Building Customer Screen");
    var customers = Provider.of<ManagerProvider>(context, listen: true).customers;

    return FocusDetector(
      onFocusGained: () {
        setState(() {});
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: appBarSize,
          child: StandardAppBar(
            "Kundbas",
            trailing: _addCustomerTextButton(),
          ),
        ),
        body: BackgroundWidget(child: _body(customers, context)),
      ),
    );
  }

  SingleChildScrollView _body(List<Customer> customers, BuildContext context) {
    return SingleChildScrollView(
      child: ListedView(
          items: List.generate(customers.length, (index) {
        Customer customer = customers[index];
        return ListedItem(
            leadingWidget: CustomerCircle(customer: customer),
            trailingIcon: Icons.chevron_right,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      customer.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(customer.address ?? "", style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600))
                ],
              ),
            ),
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context, screen: CustomerDetailsScreen(customer: customer));
            });
      })),
    );
  }

  Widget _addCustomerTextButton() {
    var user = Provider.of<ManagerProvider>(context, listen: false).user;
    if (!user.isAdmin) return Container();
    return Container(
      padding: EdgeInsets.only(right: 16),
      child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onPressedAddCustomer,
          child: Text("Lägg till", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
    );
  }

  Widget expandableHeader(int index, bool isExpanded, Customer customer) {
    return Theme(
      data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
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
              Text(customer.name, style: TextStyle(fontSize: 20)),
              Text(customer.address ?? "", style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600))
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
                    Text(contact.name, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text(contact.email ?? "", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 2),
                    Text(contact.phoneNumber)
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _onPressedAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(),
      ),
    );
  }
}
