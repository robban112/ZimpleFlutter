import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/src/provider.dart';
import 'package:zimple/model/contact.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';

import 'add_contact_screen.dart';

class ContactPersonSelectScreen extends StatelessWidget {
  final Function(Contact) didSelectContact;
  ContactPersonSelectScreen({
    Key? key,
    required this.didSelectContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Contact> contacts = context.watch<ManagerProvider>().contacts;
    return Scaffold(
      appBar: PreferredSize(preferredSize: appBarSize, child: StandardAppBar("Välj kontaktperson")),
      floatingActionButton: fab(context),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (BuildContext context, int index) {
              return ContactPersonCard(
                contact: contacts[index],
                didSelectContact: (contact) {
                  this.didSelectContact(contact);
                  Navigator.of(context).pop();
                },
              );
            }),
      ),
    );
  }

  FloatingActionButton fab(BuildContext context) => FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () => pushNewScreen(context, screen: AddContactScreen()),
      );
}

class ContactPersonCard extends StatelessWidget {
  final Contact contact;
  final Function(Contact) didSelectContact;
  const ContactPersonCard({
    Key? key,
    required this.contact,
    required this.didSelectContact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => this.didSelectContact(contact),
      child: Card(
        color: Theme.of(context).primaryColor,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 20,
        //color: Colors.yellow,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(Icons.contact_page, color: Theme.of(context).iconTheme.color),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(contact.phoneNumber, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(contact.email ?? ""),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
