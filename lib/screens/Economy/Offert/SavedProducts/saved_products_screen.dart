import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/product.dart';
import 'package:zimple/network/firebase_product_manager.dart';
import 'package:zimple/screens/Economy/Offert/SavedProducts/add_product_page.dart';
import 'package:zimple/screens/Login/components/abstract_wave_animation.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class SavedProductsScreen extends StatefulWidget {
  const SavedProductsScreen({Key? key}) : super(key: key);

  @override
  _SavedProductsScreenState createState() => _SavedProductsScreenState();
}

class _SavedProductsScreenState extends State<SavedProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Produkter", trailing: _addButton()),
      body: Stack(
        children: [
          ZimpleDotBackground(
            shouldAnimate: false,
          ),
          SavedProductsList(
            hasDelete: true,
            onDeleteProduct: deleteProduct,
            onSelectProduct: (_) {},
          )
        ],
      ),
    );
  }

  Widget _addButton() => CupertinoButton(
        onPressed: () => PersistentNavBarNavigator.pushNewScreen(context, screen: AddProductPage()),
        child: Padding(
          padding: const EdgeInsets.only(right: 0.0),
          child: Center(
            child: Text(
              "Lägg till",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'FiraSans', letterSpacing: 0.2),
            ),
          ),
        ),
      );

  void deleteProduct(Product product) {
    FirebaseProductManager.of(context).removeProduct(product);
    showSnackbar(context: context, isSuccess: false, message: "Produkt borttagen");
  }
}

class SavedProductsList extends StatelessWidget {
  final bool hasDelete;

  final Function(Product) onSelectProduct;

  final Function(Product) onDeleteProduct;

  const SavedProductsList({
    Key? key,
    required this.hasDelete,
    required this.onSelectProduct,
    required this.onDeleteProduct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  Widget _body(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: FirebaseProductManager.of(context).streamProducts(),
      builder: (context, snapshot) {
        if (snapshot.data == null) return Center(child: Text("Inga produkter"));
        return _buildProductList(snapshot.data!);
      },
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 16),
      itemBuilder: (context, index) {
        Product product = products[index];
        return ProductItem(
          product: product,
          onTapDelete: onDeleteProduct,
          hasDelete: hasDelete,
          onSelectProduct: onSelectProduct,
        );
      },
      itemCount: products.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  final Function(Product) onTapDelete;

  final Function(Product) onSelectProduct;

  final bool hasDelete;

  const ProductItem({
    Key? key,
    required this.product,
    required this.onTapDelete,
    required this.hasDelete,
    required this.onSelectProduct,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onSelectProduct(product),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        width: width(context),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ThemeNotifier.of(context).isDarkMode() ? null : standardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLeftTextCol(context),
              hasDelete ? _buildDeleteButton(context) : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return CupertinoButton(
      onPressed: () => onTapDelete(product),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeNotifier.of(context).red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(FeatherIcons.trash2, color: ThemeNotifier.of(context).red),
        ),
      ),
    );
  }

  Widget _buildLeftTextCol(BuildContext context) {
    String pricePerUnit = "${product.pricePerUnit.toInt().toString()} kr per ${unitToString(product.unit)}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: ThemeNotifier.of(context).textColor, fontFamily: 'FiraSans')),
        const SizedBox(height: 3),
        Text(pricePerUnit,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.normal, color: ThemeNotifier.of(context).textColor, fontFamily: 'FiraSans')),
        const SizedBox(height: 6),
        Text("${product.vat.toString()} % moms",
            style: textStyle(context).copyWith(color: ThemeNotifier.of(context).textColor.withOpacity(0.5)))
      ],
    );
  }
}
