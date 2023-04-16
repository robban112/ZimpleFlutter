import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/product.dart';
import 'package:zimple/network/firebase_product_manager.dart';
import 'package:zimple/screens/Economy/Offert/SavedProducts/SelectVAT/select_vat_screen.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController pricePerUnitController = TextEditingController();

  String selectedUnit = "timmar";

  int selectedVat = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Lägg till produkt", trailing: SaveTextButton(onTapSave: _onTapSave)),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: _body(context),
        ),
      ]),
    );
  }

  Widget _body(BuildContext context) {
    return ListedView(items: [
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Produkttitel',
        controller: titleController,
      ),
      ListedTextField(
        leadingIcon: Icons.price_change,
        placeholder: 'Pris per enhet',
        controller: pricePerUnitController,
        inputType: TextInputType.number,
      ),
      ListedItem(
        leadingIcon: Icons.category_sharp,
        text: 'Enhet',
        trailingWidget: Row(
          children: [Text(selectedUnit), Icon(Icons.chevron_right)],
        ),
      ),
      ListedItem(
        leadingIcon: Icons.category_sharp,
        text: 'Moms',
        onTap: _onTapSelectVAT,
        trailingWidget: Row(
          children: [Text(selectedVat.toString()), Icon(Icons.chevron_right)],
        ),
      ),
    ]);
  }

  void _onTapSave() {
    Product product = Product(
      id: "",
      vat: selectedVat,
      name: titleController.text,
      pricePerUnit: double.parse(pricePerUnitController.text),
      unit: unitFromString(
        selectedUnit,
      ),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    FirebaseProductManager.of(context).addProduct(product).then((_) {
      Navigator.of(context).pop();
      Future.delayed(Duration(milliseconds: 300), () {
        showSnackbar(context: context, isSuccess: true, message: "Produkt tillagd!");
      });
    });
  }

  void _onTapSelectVAT() async {
    var vat = await PersistentNavBarNavigator.pushNewScreen(context,
        screen: SelectVATPage(
          selectedVat: selectedVat,
        ));
    if (vat is int) {
      setState(() => this.selectedVat = vat);
    }
  }
}
