import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/utils/generic_imports.dart';

class CustomerManager {
  List<Customer> customers;

  CustomerManager({required this.customers});

  static CustomerManager of(BuildContext context) => context.read<ManagerProvider>().customerManager;

  Customer? getCustomer(String? customerKey) {
    if (customerKey == null) return null;
    if (customers.length == 0) return null;
    Customer? customer;
    try {
      customer = customers.firstWhere((customer) => customer.id == customerKey, orElse: null);
    } catch (error) {
      print("Error while trying to parse customer: $error");
      return null;
    }
    return customer;
  }
}
