import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/person_manager.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_company_manager.dart';
import 'package:zimple/network/firebase_contact_manager.dart';
import 'package:zimple/network/firebase_customer_manager.dart';
import 'package:zimple/network/firebase_drive_journal_manager.dart';
import 'package:zimple/network/firebase_event_manager.dart';
import 'package:zimple/network/firebase_notes_manager.dart';
import 'package:zimple/network/firebase_person_manager.dart';
import 'package:zimple/network/firebase_product_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/network/firebase_user_manager.dart';
import 'package:zimple/utils/service/profile_picture_service.dart';

class ManagerProvider extends ChangeNotifier {
  PersonManager personManager = PersonManager(persons: []);

  EventManager eventManager = EventManager(events: []);

  late UserParameters user;

  List<Customer> customers = [];

  late FirebaseCustomerManager firebaseCustomerManager;

  late FirebasePersonManager firebasePersonManager;

  late FirebaseEventManager firebaseEventManager;

  late FirebaseUserManager firebaseUserManager;

  late FirebaseTimeReportManager firebaseTimereportManager;

  late FirebaseContactManager firebaseContactManager;

  late FirebaseCompanyManager firebaseCompanyManager;

  late TimereportManager timereportManager;

  late FirebaseDriveJournalManager firebaseDriveJournalManager;

  CustomerManager customerManager = CustomerManager(customers: []);

  late FirebaseNotesManager firebaseNotesManager;

  ProfilePictureService? profilePictureService;

  CompanySettings companySettings = CompanySettings.initial();

  List<Contact> contacts = [];

  Map<String, int>? absenceRequestReadMap;

  bool mounted = false;

  FirebaseProductManager get firebaseProductManager => FirebaseProductManager(company: this.user.company);

  final ValueNotifier<String?> eventIdMessageOpen = ValueNotifier(null);

  static ManagerProvider of(BuildContext context) {
    return context.read<ManagerProvider>();
  }

  static ManagerProvider watch(BuildContext context) {
    return context.watch<ManagerProvider>();
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

  Future<void> initProfilePictureService() async {
    this.profilePictureService = ProfilePictureService(
        profilePicturePaths: personManager.getProfilePicturePaths(),
        firebaseStorageManager: FirebaseStorageManager(company: user.company));
    return profilePictureService?.init();
  }

  Person? getLoggedInPerson() {
    return personManager.getPersonById(user.token);
  }

  Image? getLoggedInUserImage() {
    return getPersonImage(getLoggedInPerson());
  }

  Image? getPersonImage(Person? person) {
    return profilePictureService?.getProfilePicture(person?.profilePicturePath);
  }

  Image? getPersonImageById(String? id) {
    if (id == null) return null;
    Person? person = personManager.getPersonById(id);
    return profilePictureService?.getProfilePicture(person?.profilePicturePath);
  }

  Customer? getCustomer(String key) {
    return customerManager.getCustomer(key);
  }
}

class ProviderWidget extends InheritedWidget {
  const ProviderWidget({required this.drawerKey, required this.child, required this.didTapEvent}) : super(child: child);
  final GlobalKey<ScaffoldState> drawerKey;
  final Function(Event) didTapEvent;
  final Widget child;

  static ProviderWidget of(BuildContext context) {
    final ProviderWidget result = context.dependOnInheritedWidgetOfExactType<ProviderWidget>()!;
    return result;
  }

  @override
  bool updateShouldNotify(ProviderWidget old) => key != old.key;
}
