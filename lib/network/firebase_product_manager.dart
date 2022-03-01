import 'package:firebase_database/firebase_database.dart' as fb;
import 'package:flutter/widgets.dart';
import 'package:zimple/model/product.dart';
import 'package:zimple/widgets/widgets.dart';

class FirebaseProductManager {
  String company;
  late fb.DatabaseReference database;
  late fb.DatabaseReference productRef;

  FirebaseProductManager({required this.company}) {
    database = fb.FirebaseDatabase.instance.ref();
    productRef = database.ref.child(company).child('Products');
  }

  static FirebaseProductManager of(BuildContext context) => ManagerProvider.of(context).firebaseProductManager;

  Future<void> addProduct(Product product) => productRef.push().set(product.toMap());

  Future<void> removeProduct(Product product) => productRef.child(product.id).remove();

  Stream<List<Product>> streamProducts() => productRef.onValue.map((event) => _mapSnapshot(event.snapshot));

  List<Product> _mapSnapshot(fb.DataSnapshot snapshot) {
    if (snapshot.value == null) return [];
    try {
      Map<String, dynamic> mapOfProducts = Map.from(snapshot.value as Map<dynamic, dynamic>);
      List<Product> products = [];
      for (String key in mapOfProducts.keys) {
        Map<String, dynamic> productData = Map.from(mapOfProducts[key]);
        Product contact = Product.fromMap(key, productData);
        products.add(contact);
      }
      //List<Contact> contacts = mapOfContacts.keys.map((e) => Contact.fromJson(mapOfContacts[e])).toList();
      return products;
    } catch (error) {
      print("error parsing contacts: $error");
      return [];
    }
  }
}
