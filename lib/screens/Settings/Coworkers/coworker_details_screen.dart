import 'package:flutter/material.dart';
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

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.person.name);
    _phoneController = TextEditingController(text: widget.person.phonenumber);
    _emailController = TextEditingController(text: widget.person.email);
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
                _buildChangeColorRow()
              ]),
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
      color: selectedNewColor ?? widget.person.color,
    );
    context.read<ManagerProvider>().firebasePersonManager.setUserProps(newPerson);
    context.read<ManagerProvider>().updatePerson(newPerson);
    Navigator.of(context).pop();
  }
}
