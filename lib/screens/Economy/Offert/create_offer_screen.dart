import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/screens/Economy/Offert/Components/invoice_item_widget.dart';
import 'package:zimple/screens/Economy/Offert/CreatedOffer/created_offer_screen.dart';
import 'package:zimple/screens/Economy/Offert/OfferPreview/offer_preview_screen.dart';
import 'package:zimple/screens/Economy/Offert/SelectProduct/select_product_screen.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/invoice.dart';
import 'package:zimple/screens/TimeReporting/Invoice/model/supplier.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({Key? key}) : super(key: key);

  @override
  _CreateOfferScreenState createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  static const double spacing = 16;

  static const EdgeInsets rowInset = EdgeInsets.symmetric(vertical: 12);

  late final TextEditingController senderController =
      TextEditingController(text: ManagerProvider.of(context).getLoggedInPerson()?.name);

  late final TextEditingController receiverController = TextEditingController();

  late final TextEditingController orgController = TextEditingController(text: CompanySettings.of(context).orgNr);

  late final TextEditingController momsController = TextEditingController(text: CompanySettings.of(context).vatNr);

  late final TextEditingController nameController = TextEditingController(text: CompanySettings.of(context).companyName);

  late final TextEditingController websiteController = TextEditingController(text: CompanySettings.of(context).website);

  late final TextEditingController bankgiroController = TextEditingController(text: CompanySettings.of(context).bankgiro);

  late final TextEditingController plusgiroController = TextEditingController(text: CompanySettings.of(context).plusgiro);

  late final TextEditingController ibanController = TextEditingController(text: CompanySettings.of(context).iban);

  late final TextEditingController emailController = TextEditingController(text: user(context).email);

  late final TextEditingController phoneController =
      TextEditingController(text: ManagerProvider.of(context).getLoggedInPerson()?.phonenumber);

  final TextEditingController termsController = TextEditingController();

  final TextEditingController descController = TextEditingController();

  List<InvoiceItem> selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Skapa offert", trailing: ZTextButton(text: "Skapa", onTap: _onTapCreateOffer)),
      body: BackgroundWidget(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapRemoveFocus(context),
      child: Container(
        height: height(context),
        width: width(context),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreviewOffer(),
              Text("Information", style: titleStyle),
              smallDivider(),
              _buildInformationInputFields(),
              divider(),
              Text("Företagsinfo", style: titleStyle),
              smallDivider(),
              _buildCompanyInfoInputFields(),
              divider(),
              Text("Bank uppgifter", style: titleStyle),
              smallDivider(),
              _buildBankInfoInputFields(),
              divider(),
              Text("Produkter / Tjänster", style: titleStyle),
              smallDivider(),
              _buildAddProductsFields(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProductsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        smallDivider(),
        Wrap(
          runSpacing: 8,
          children: List.generate(
            selectedProducts.length,
            (index) => ProductAmountItem(
              productAmount: selectedProducts[index],
              onTapDeleteProduct: () => _onDeleteAddedProduct(selectedProducts[index]),
            ),
          ),
        ),
        divider(),
        Container(
          width: width(context),
          child: CupertinoButton(
            onPressed: _onTapSelectProduct,
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ThemeNotifier.of(context).textColor,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Text("+ Lägg till produkt", style: textStyle(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget divider() => const SizedBox(height: spacing);

  Widget smallDivider() => const SizedBox(height: 6);

  ListedView _buildBankInfoInputFields() {
    return ListedView(
      rowInset: EdgeInsets.symmetric(vertical: 12),
      items: [
        ListedTextField(leadingIcon: Icons.title, placeholder: 'Bankgiro', controller: bankgiroController),
        ListedTextField(
          leadingIcon: Icons.title,
          placeholder: 'Plusgiro',
          controller: plusgiroController,
        ),
        ListedTextField(
          leadingIcon: Icons.title,
          placeholder: 'IBAN',
          controller: ibanController,
        ),
      ],
    );
  }

  ListedView _buildCompanyInfoInputFields() {
    return ListedView(
      rowInset: EdgeInsets.symmetric(vertical: 12),
      items: [
        ListedTextField(leadingIcon: Icons.title, placeholder: 'Organisationsnummer', controller: orgController),
        ListedTextField(
          leadingIcon: Icons.title,
          placeholder: 'Företagsnamn',
          controller: nameController,
        ),
        ListedTextField(
          leadingIcon: Icons.title,
          placeholder: 'Moms registreringsnummer',
          controller: momsController,
        ),
        ListedTextField(
          leadingIcon: Icons.title,
          placeholder: 'Företagets hemsida',
          controller: websiteController,
        ),
      ],
    );
  }

  ListedView _buildInformationInputFields() {
    return ListedView(rowInset: EdgeInsets.symmetric(vertical: 12), items: [
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Mottagare',
        controller: receiverController,
      ),
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Avsändare',
        controller: senderController,
      ),
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Din email',
        controller: emailController,
      ),
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Ditt telefonnummer',
        controller: phoneController,
      ),
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Betalningsvillkor',
        controller: termsController,
        inputType: TextInputType.number,
      ),
      ListedTextField(
        leadingIcon: Icons.title,
        placeholder: 'Beskrivning',
        controller: descController,
      ),
    ]);
  }

  Widget _buildPreviewOffer() {
    return Container(
      width: width(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(child: Align(alignment: Alignment.centerLeft, child: Text("Förhandsvisning", style: titleStyle))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _onPresedPreviewOffer,
            child: Container(
              width: width(context) * 0.4,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Theme.of(context).cardColor,
                    child: OfferPDF(
                      invoice: getInvoice(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _onPresedPreviewOffer() {
    showCupertinoDialog(context: context, builder: (_) => OfferPreviewScreen(invoice: getInvoice()));
  }

  void _onTapSelectProduct() async {
    var amountProduct = await PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: SelectProductScreen(),
    );
    if (amountProduct is InvoiceItem) setState(() => selectedProducts.add(amountProduct));
  }

  void _onDeleteAddedProduct(InvoiceItem productAmount) => setState(() => selectedProducts.remove(productAmount));

  void _onTapCreateOffer() {
    PersistentNavBarNavigator.pushNewScreen(context, screen: CreatedOfferScreen(invoice: getInvoice()));
  }

  Invoice getInvoice() {
    InvoiceInfo info = InvoiceInfo(
      date: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: 30)),
      description: descController.text,
      number: '${DateTime.now().year}-${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}',
    );

    Supplier supplier = Supplier(
      name: senderController.text,
      address: '',
      paymentInfo: '',
      phonenumber: phoneController.text,
      email: emailController.text,
    );

    BankInfo bankInfo = BankInfo(bankgiro: bankgiroController.text, plusgiro: plusgiroController.text, iban: ibanController.text);

    CompanyInfo companyInfo = CompanyInfo(orgNr: orgController.text, vatNr: momsController.text, website: websiteController.text);

    Customer customer = Customer(receiverController.text, '', '', []);

    return Invoice(
      title: 'Offert',
      info: info,
      supplier: supplier,
      customer: customer,
      items: selectedProducts,
      bankInfo: bankInfo,
      companyInfo: companyInfo,
    );
  }
}
