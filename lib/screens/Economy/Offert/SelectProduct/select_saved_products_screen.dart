import 'package:flutter/material.dart';
import 'package:zimple/model/product.dart';
import 'package:zimple/screens/Economy/Offert/SavedProducts/saved_products_screen.dart';
import 'package:zimple/widgets/widgets.dart';

class SelectSavedProductScreen extends StatefulWidget {
  const SelectSavedProductScreen({Key? key}) : super(key: key);

  @override
  State<SelectSavedProductScreen> createState() => _SelectSavedProductScreenState();
}

class _SelectSavedProductScreenState extends State<SelectSavedProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Välj produkt"),
      body: SavedProductsList(
        hasDelete: false,
        onDeleteProduct: (_) {},
        onSelectProduct: (Product product) => Navigator.of(context).pop(product),
      ),
    );
  }
}
