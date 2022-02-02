import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/zimpletextfield.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/widgets.dart';

class EnterEmailStep extends StatefulWidget {
  final Function(String) onSubmit;

  final String? email;

  final FocusNode focusNode;

  EnterEmailStep({
    Key? key,
    required this.onSubmit,
    required this.email,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<EnterEmailStep> createState() => _EnterEmailStepState();
}

class _EnterEmailStepState extends State<EnterEmailStep> {
  late final TextEditingController controller = TextEditingController(text: widget.email);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();

  final UniqueKey key = UniqueKey();

  bool autoValidate = false;

  @override
  Widget build(BuildContext context) {
    print("rebuilt enter email");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        key: key,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //const SizedBox(height: 70),
          Text("Skriv in din email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ZTextfield(
            focusNode: widget.focusNode,
            formKey: formKey,
            inputType: TextInputType.emailAddress,
            controller: controller,
            hintText: 'Email',
            prefixIcon: Icon(Icons.email),
            validator: emailValidator,
            autoValidateMode: autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
          ),
          //Expanded(child: Container()),
          const SizedBox(height: 24),
          _nextButton()
        ],
      ),
    );
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
    print("validate");
    setState(() {
      autoValidate = true;
    });
    formKey.currentState?.validate();
    bool isValidEmail = emailValidator(controller.text) == null;
    if (isValidEmail) widget.onSubmit(controller.text);
  }
}
