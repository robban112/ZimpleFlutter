import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/widgets/listed_view/listed_switch.dart';
import 'package:zimple/widgets/snackbar/snackbar_widget.dart';
import 'package:zimple/widgets/widgets.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({Key? key}) : super(key: key);

  @override
  _CompanySettingsScreenState createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  late final TextEditingController companyNameController = TextEditingController(text: CompanySettings.of(context).companyName);
  late final TextEditingController companyOrgNrController = TextEditingController(text: CompanySettings.of(context).orgNr);
  late final TextEditingController companyVatNrController = TextEditingController(text: CompanySettings.of(context).vatNr);
  late final TextEditingController companyWebsiteController = TextEditingController(text: CompanySettings.of(context).website);

  late final TextEditingController bankgiroController = TextEditingController(text: CompanySettings.of(context).bankgiro);
  late final TextEditingController plusgiroController = TextEditingController(text: CompanySettings.of(context).plusgiro);
  late final TextEditingController ibanController = TextEditingController(text: CompanySettings.of(context).iban);

  late bool approvedForFTax = CompanySettings.of(context).approvedForFTax ?? true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Företagsinfo", trailing: _saveButton()),
      body: BackgroundWidget(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ListedTitle(text: "Företagsinfo"),
          ListedView(
            items: [
              ListedTextField(
                leadingIcon: Icons.title,
                placeholder: 'Företagsnamn',
                controller: companyNameController,
              ),
              ListedTextField(
                leadingIcon: FeatherIcons.briefcase,
                placeholder: 'Organisations nummer',
                controller: companyOrgNrController,
              ),
              ListedTextField(
                leadingIcon: FeatherIcons.briefcase,
                placeholder: 'Moms registrerings nummer',
                controller: companyVatNrController,
              ),
              ListedTextField(
                leadingIcon: Icons.title,
                placeholder: 'Företagets hemsida',
                controller: companyWebsiteController,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListedTitle(text: "Bank info"),
          ListedView(
            items: [
              ListedTextField(
                leadingIcon: FeatherIcons.briefcase,
                placeholder: 'Bankgiro',
                controller: bankgiroController,
              ),
              ListedTextField(
                leadingIcon: FeatherIcons.briefcase,
                placeholder: 'Plusgiro',
                controller: plusgiroController,
              ),
              ListedTextField(
                leadingIcon: FeatherIcons.briefcase,
                placeholder: 'IBAN',
                controller: ibanController,
              ),
              ListedSwitch(text: "Godkänd för F-skatt", initialValue: approvedForFTax, onChanged: (val) => approvedForFTax = val),
            ],
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return CupertinoButton(
      onPressed: _onTapSave,
      child: Center(
        child: Text(
          "Spara",
          style: TextStyle(color: Colors.white, fontFamily: 'FiraSans', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _onTapSave() {
    String name = companyNameController.text;
    String orgNr = companyOrgNrController.text;
    String vat = companyVatNrController.text;
    String website = companyWebsiteController.text;
    String bankgiro = bankgiroController.text;
    String plusgiro = plusgiroController.text;
    String iban = ibanController.text;

    CompanySettings newCompanySettings = CompanySettings.of(context).copyWith(
      companyName: name,
      orgNr: orgNr,
      vatNr: vat,
      website: website,
      bankgiro: bankgiro,
      plusgiro: plusgiro,
      iban: iban,
      approvedForFTax: approvedForFTax,
    );
    ManagerProvider.of(context)
        .firebaseCompanyManager
        .updateCompanySettings(companySettings: newCompanySettings)
        .then((value) => _onSaved());
  }

  void _onSaved() {
    Navigator.of(context).pop();
    Future.delayed(Duration(milliseconds: 300), () {
      String message = "Företagsinfo ändrat!";
      showSnackbar(context: context, isSuccess: true, message: message);
    });
  }
}
