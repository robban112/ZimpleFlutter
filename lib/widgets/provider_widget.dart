import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_company_manager.dart';
import 'package:zimple/network/firebase_contact_manager.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_person_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/network/firebase_user_manager.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';

class ManagerProvider extends ChangeNotifier {
  late PersonManager personManager;

  late EventManager eventManager;

  late UserParameters user;

  late List<Customer> customers;

  late FirebaseCustomerManager firebaseCustomerManager;

  late FirebasePersonManager firebasePersonManager;

  late FirebaseEventManager firebaseEventManager;

  late FirebaseUserManager firebaseUserManager;

  late FirebaseTimeReportManager firebaseTimereportManager;

  late FirebaseContactManager firebaseContactManager;

  late FirebaseCompanyManager firebaseCompanyManager;

  late TimereportManager timereportManager;

  late CustomerManager customerManager;

  CompanySettings companySettings = CompanySettings.initial();

  List<Contact> contacts = [];
  Map<String, int>? absenceRequestReadMap;

  static ManagerProvider of(BuildContext context) {
    return context.read<ManagerProvider>();
  }

  void setContacts(List<Contact> contacts) {
    this.contacts = contacts;
    notifyListeners();
  }

  void updatePerson(Person person) {
    personManager.updatePerson(person);
    notifyListeners();
  }

  void setPersons(List<Person> persons) {
    this.personManager = PersonManager(persons: persons);
    notifyListeners();
  }

  void setEventManager(EventManager eventManager) {
    this.eventManager = eventManager;
    notifyListeners();
  }

  void updateEvent({required String key, required Event newEvent}) {
    this.eventManager.updateEvent(key: key, newEvent: newEvent);
    notifyListeners();
  }

  void updateCompanySettings({required CompanySettings companySettings}) {
    this.companySettings = companySettings;
    notifyListeners();
  }
}

class ProviderWidget extends InheritedWidget {
  const ProviderWidget({required this.drawerKey, required this.child, required this.didTapEvent}) : super(child: child);
  final GlobalKey<ScaffoldState> drawerKey;
  final Function(Event) didTapEvent;
  final Widget child;

  static ProviderWidget of(BuildContext context) {
    final ProviderWidget result = context.dependOnInheritedWidgetOfExactType<ProviderWidget>()!;
    assert(result != null, '');
    return result;
  }

  @override
  bool updateShouldNotify(ProviderWidget old) => key != old.key;
}
