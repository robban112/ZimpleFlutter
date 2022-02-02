import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/zimpletextfield.dart';
import 'package:zimple/widgets/widgets.dart';

class EnterPhonenumberStep extends StatefulWidget {
  final Function(String) onSubmit;

  final String? phonenumber;

  final FocusNode focusNode;

  EnterPhonenumberStep({
    Key? key,
    required this.onSubmit,
    required this.phonenumber,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<EnterPhonenumberStep> createState() => _EnterPhonenumberStepState();
}

class _EnterPhonenumberStepState extends State<EnterPhonenumberStep> {
  late final TextEditingController controller = TextEditingController(text: widget.phonenumber);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final UniqueKey key = UniqueKey();

  bool autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //const SizedBox(height: 70),
          Text("Ditt telefonnummer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ZTextfield(
            focusNode: widget.focusNode,
            formKey: formKey,
            inputType: TextInputType.phone,
            controller: controller,
            hintText: '070 000 00 00',
            prefixIcon: Icon(Icons.calendar_today),
            validator: phoneValidator,
            autoValidateMode: autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
          ),
          //Expanded(child: Container()),
          const SizedBox(height: 24),
          _nextButton()
        ],
      ),
    );
  }

  String? phoneValidator(String? value) {
    if (value == null) return null;

    if (value.isEmpty) return '* Skriv in ett telefonnummer';
    bool validPhonenumber = _validatePhonenumber(value);
    return validPhonenumber ? null : " * Skriv in ett korrekt telefonnummer";
  }

  static bool _validatePhonenumber(String phone) {
    String pattern = r'(^((((0{2}?)|(\+){1})46)|0|1)[\d]{9})';
    return RegExp(pattern).hasMatch(phone);
  }

  Row _nextButton() {
    return Row(
      children: [
        Expanded(
          child: RectangularButton(
            onTap: onTapNext,
            text: 'Nästa',
          ),
        ),
      ],
    );
  }

  void onTapNext() {
    setState(() {
      autoValidate = true;
    });
    formKey.currentState?.validate();
    bool isValidEmail = phoneValidator(controller.text) == null;
    if (isValidEmail) widget.onSubmit(controller.text);
  }
}
