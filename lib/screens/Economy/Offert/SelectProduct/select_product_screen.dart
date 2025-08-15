import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/model/product.dart';
import 'package:zimple/screens/Economy/Offert/SelectProduct/select_saved_products_screen.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/invoice.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class SelectProductScreen extends StatefulWidget {
  const SelectProductScreen({Key? key}) : super(key: key);

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController amountController = TextEditingController();

  final TextEditingController pricePerUnitController = TextEditingController();

  final TextEditingController vatController = TextEditingController(text: "25");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Välj produkt", trailing: SaveTextButton(onTapSave: _onTapSave)),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return ListedView(items: [
      ListedItem(
        text: "Förifyll från produkt",
        onTap: _onTapSelectSavedProduct,
      ),
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Namn',
        controller: nameController,
      ),
      ListedTextField(
        leadingIcon: FeatherIcons.dollarSign,
        placeholder: 'Pris per enhet',
        controller: pricePerUnitController,
        inputType: TextInputType.number,
      ),
      ListedTextField(
        leadingIcon: Icons.format_list_numbered,
        placeholder: 'Antal',
        controller: amountController,
        inputType: TextInputType.number,
      ),
      ListedTextField(
        leadingIcon: Icons.format_list_numbered,
        placeholder: 'Moms',
        controller: vatController,
        inputType: TextInputType.number,
      ),
    ]);
  }

  void _onTapSelectSavedProduct() async {
    var product = await PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: SelectSavedProductScreen(),
    );
    if (product is Product) {
      nameController.text = product.name;
      pricePerUnitController.text = product.pricePerUnit.toInt().toString();
      vatController.text = product.vat.toString();
    }
  }

  void _onTapSave() {
    if (nameController.text.isEmpty) {
      showSnackbar(context: context, isSuccess: false, message: "Fyll i namn");
      return;
    }

    if (pricePerUnitController.text.isEmpty) {
      showSnackbar(context: context, isSuccess: false, message: "Fyll i pris per enhet");
      return;
    }

    if (amountController.text.isEmpty) {
      showSnackbar(context: context, isSuccess: false, message: "Fyll i antal");
      return;
    }

    if (vatController.text.isEmpty) {
      showSnackbar(context: context, isSuccess: false, message: "Fyll i moms");
      return;
    }

    try {
      onTapRemoveFocus(context);
      Future.delayed(Duration(milliseconds: 100), () {
        Navigator.of(context).pop(InvoiceItem(
          vat: double.parse(vatController.text),
          date: DateTime.now(),
          description: nameController.text,
          quantity: int.parse(amountController.text),
          unitPrice: double.parse(pricePerUnitController.text),
        ));
      });
    } catch (e) {
      showSnackbar(context: context, isSuccess: false, message: "Det blev något fel");
      return;
    }
  }
}
