import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:provider/src/provider.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/utils/color_utils.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:zimple/widgets/listed_view.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:zimple/widgets/widgets.dart';

class CoworkerDetailsScreen extends StatefulWidget {
  final Person person;
  const CoworkerDetailsScreen({
    Key? key,
    required this.person,
  }) : super(key: key);

  @override
  State<CoworkerDetailsScreen> createState() => _CoworkerDetailsScreenState();
}

class _CoworkerDetailsScreenState extends State<CoworkerDetailsScreen> {
  Color? selectedNewColor;

  late TextEditingController _nameController;

  late TextEditingController _phoneController;

  late TextEditingController _emailController;

  late TextEditingController _ssnController;

  late TextEditingController _addressController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.person.name);
    _phoneController = TextEditingController(text: widget.person.phonenumber);
    _emailController = TextEditingController(text: widget.person.email);
    _ssnController = TextEditingController(text: widget.person.ssn);
    _addressController = TextEditingController(text: widget.person.address);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: StandardAppBar(
            widget.person.name,
            trailing: _buildTrailing(),
          )),
      body: _body(),
    );
  }

  Widget _body() => GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          color: Theme.of(context).backgroundColor,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListedView(items: [
                ListedTextField(placeholder: 'Namn', leadingIcon: Icons.menu, controller: _nameController),
                ListedTextField(
                    placeholder: 'Email',
                    leadingIcon: Icons.email,
                    controller: _emailController,
                    inputType: TextInputType.emailAddress),
                ListedTextField(
                    placeholder: 'Telefonnummer',
                    leadingIcon: Icons.phone,
                    controller: _phoneController,
                    inputType: TextInputType.phone),
                ListedTextField(
                    placeholder: 'Personnummer',
                    leadingIcon: FontAwesome5.user,
                    controller: _ssnController,
                    inputType: TextInputType.number),
                ListedTextField(
                    placeholder: 'Address',
                    leadingIcon: Icons.location_city,
                    controller: _addressController,
                    inputType: TextInputType.text),
                _buildChangeColorRow(),
              ]),
              _buildMagicLinks(),
            ],
          ).padding(vertical: 8),
        ),
      );

  ListedItem _buildChangeColorRow() {
    return ListedItem(
        onTap: () => pickColor(),
        trailingIcon: Icons.chevron_right,
        child: Row(
          children: [
            Container(height: 24, width: 24).decorated(color: selectedNewColor ?? widget.person.color, shape: BoxShape.circle),
            SizedBox(width: 16),
            Text("Ändra färg", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
          ],
        ));
  }

  Widget _buildTrailing() => Center(
        child: TextButton(
          onPressed: () => savePerson(context),
          child: Text("Spara",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ),
      ).padding(right: 0);

  Widget _buildMagicLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildMagicLinkSection("iOS Magisk Länk", widget.person.iOSLink),
          _buildMagicLinkSection("Android Magisk Länk", widget.person.androidLink),
        ],
      ),
    );
  }

  Widget _buildMagicLinkSection(String title, String? magicLink) {
    if (magicLink == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        _buildCopyTextButton(magicLink),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCopyTextButton(String text) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        FlutterClipboard.copy(text).then((_) {
          final snackBar = SnackBar(
            content: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Kopierat!'),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      },
      child: Text(
        text,
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }

  void pickColor() {
    Color pickedColor = widget.person.color;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Välj en färg'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: widget.person.color,
            onColorChanged: (color) => pickedColor = color,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              setState(() => selectedNewColor = pickedColor);
              Navigator.of(context, rootNavigator: true).pop(null);
            },
          ),
        ],
      ),
    );
  }

  void savePerson(BuildContext context) {
    Person newPerson = Person(
      id: widget.person.id,
      name: _nameController.text,
      phonenumber: _phoneController.text,
      email: _emailController.text,
      ssn: _ssnController.text,
      color: selectedNewColor ?? widget.person.color,
      address: _addressController.text,
    );
    context.read<ManagerProvider>().firebasePersonManager.setUserProps(newPerson);
    context.read<ManagerProvider>().updatePerson(newPerson);
    Navigator.of(context).pop();
  }
}
