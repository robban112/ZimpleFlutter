import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/utils/constants.dart';

class CustomerSelectScreen extends StatefulWidget {
  final Function(Customer, int) didSelectCustomer;
  CustomerSelectScreen({required this.didSelectCustomer});
  @override
  _CustomerSelectScreenState createState() => _CustomerSelectScreenState();
}

class _CustomerSelectScreenState extends State<CustomerSelectScreen> {
  late List<Customer> customers;
  late Map<Customer, int> selectedContact;

  @override
  void initState() {
    customers = Provider.of<ManagerProvider>(context, listen: false).customers;
    selectedContact = Map.fromIterable(customers,
        key: (customer) => customer, value: (val) => 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text("Välj kund och kontaktperson"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: buildBody());
  }

  Widget buildBody() {
    if (customers.isEmpty) {
      return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Inga kunder kunde hittas i kundbasen",
                    style:
                        TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.0),
                Text(
                    "Lägg till kunder genom att gå till Verktyg i appen. Tryck sedan på kunder och här kan du enkelt lägga till kunder.",
                    style: TextStyle(fontSize: 19.0)),
              ],
            ),
          ));
    }
    return ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey.shade300,
          );
        },
        itemCount: customers.length,
        itemBuilder: (context, index) {
          var customer = customers[index];
          return ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 18.0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0)),
                Text(customer.address),
                SizedBox(height: 10),
                ContactSelect(
                  customer: customer,
                  didSelectContact: (index) {
                    print(index);
                    selectedContact[customer] = index;
                  },
                )
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              print(selectedContact[customer]);
              widget.didSelectCustomer(customer, selectedContact[customer]!);
            },
          );
        });
  }
}

class ContactSelect extends StatefulWidget {
  const ContactSelect(
      {Key? key, required this.customer, required this.didSelectContact})
      : super(key: key);

  final Customer customer;
  final Function(int) didSelectContact;

  @override
  _ContactSelectState createState() => _ContactSelectState();
}

class _ContactSelectState extends State<ContactSelect> {
  var _selectedContact = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.customer.contacts.length > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.customer.contacts.length,
                    itemBuilder: (context, index) {
                      var contact = widget.customer.contacts[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              index == 0
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: Text("Kontaktperson",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.0)),
                                    )
                                  : Container(),
                              Text(contact.name),
                            ],
                          ),
                          widget.customer.contacts.length > 1
                              ? Radio(
                                  groupValue: _selectedContact,
                                  onChanged: (val) {
                                    widget.didSelectContact(index);
                                    setState(() {
                                      _selectedContact = index;
                                    });
                                  },
                                  value: index)
                              : Container()
                        ],
                      );
                    }),
              ],
            ),
          )
        : Container();
  }
}
