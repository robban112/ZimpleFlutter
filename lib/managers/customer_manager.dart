import 'package:zimple/model/customer.dart';

class CustomerManager {
  List<Customer> customers;
  CustomerManager({required this.customers});

  Customer? getCustomer(String customerKey) {
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
