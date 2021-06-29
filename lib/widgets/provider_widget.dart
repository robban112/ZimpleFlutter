import 'package:flutter/material.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/user_parameters.dart';
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
  late TimereportManager timereportManager;
  Map<String, int>? absenceRequestReadMap;
}

class ProviderWidget extends InheritedWidget {
  const ProviderWidget(
      {required this.drawerKey, required this.child, required this.didTapEvent})
      : super(child: child);
  final GlobalKey<ScaffoldState> drawerKey;
  final Function(Event) didTapEvent;
  final Widget child;

  static ProviderWidget of(BuildContext context) {
    final ProviderWidget result =
        context.dependOnInheritedWidgetOfExactType<ProviderWidget>()!;
    assert(result != null, '');
    return result;
  }

  @override
  bool updateShouldNotify(ProviderWidget old) => key != old.key;
}
