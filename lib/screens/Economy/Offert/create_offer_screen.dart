import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/screens/Economy/Offert/OfferPreview/offer_preview_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({Key? key}) : super(key: key);

  @override
  _CreateOfferScreenState createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  static const double spacing = 16;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(appBarHeight), child: StandardAppBar("Skapa offert")),
      body: _body(context),
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
            ],
          ),
        ),
      ),
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
        placeholder: 'Betalningsvillkor',
        controller: senderController,
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
          Container(
            width: width(context) * 0.5,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: _onPresedPreviewOffer,
                child: OfferPage(
                  aspectRatio: 0.5,
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
    showCupertinoDialog(context: context, builder: (_) => OfferPreviewScreen());
  }
}
