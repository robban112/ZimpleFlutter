import 'package:flutter/material.dart';
import 'package:loader_overlay/src/overlay_controller_widget_extension.dart';
import 'package:provider/src/provider.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_contact_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';

class AddContactScreen extends StatelessWidget {
  AddContactScreen({Key? key}) : super(key: key);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(60), child: StandardAppBar("Ny kontakt")),
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListedView(
                hidesFirstLastSeparator: true,
                rowInset: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                items: _items(),
              ),
              _saveButton(context),
            ],
          ),
        ));
  }

  List<ListedItem> _items() => [
        ListedTextField(
          leadingIcon: Icons.short_text,
          placeholder: 'Namn',
          controller: _nameController,
        ),
        ListedTextField(
            leadingIcon: Icons.phone, placeholder: 'Telefonnummer', controller: _phoneController, inputType: TextInputType.phone),
        ListedTextField(
            leadingIcon: Icons.email, placeholder: 'Email', controller: _emailController, inputType: TextInputType.emailAddress),
      ];

  Widget _saveButton(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(child: RectangularButton(onTap: () => this.onTapSave(context), text: 'Spara')),
          ],
        ),
      );

  bool validate() {
    bool hasName = _nameController.text.isNotEmpty;
    bool hasPhone = _phoneController.text.isNotEmpty;
    return hasName && hasPhone;
  }

  void onTapSave(BuildContext context) {
    if (!validate()) {
      return;
    }
    context.loaderOverlay.show();
    Contact contact = Contact("", _nameController.text, _phoneController.text, _emailController.text);
    FirebaseContactManager fbContactManager = context.read<ManagerProvider>().firebaseContactManager;
    fbContactManager.addContact(contact).then((_) {
      context.loaderOverlay.hide();
      Navigator.of(context).pop();
    });
  }
}
