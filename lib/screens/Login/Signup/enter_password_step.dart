import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/components/zimpletextfield.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/widgets.dart';

class EnterPasswordStep extends StatefulWidget {
  final Function(String) onSubmit;

  final String? password;

  final FocusNode focusNode;

  EnterPasswordStep({
    Key? key,
    required this.onSubmit,
    required this.password,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<EnterPasswordStep> createState() => _EnterPasswordStepState();
}

class _EnterPasswordStepState extends State<EnterPasswordStep> {
  late final TextEditingController controller = TextEditingController(text: widget.password);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();

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
          Text("Välj ett lösenord", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ZTextfield(
            focusNode: widget.focusNode,
            formKey: formKey,
            inputType: TextInputType.text,
            controller: controller,
            hintText: 'Lösenord',
            prefixIcon: Icon(Icons.lock),
            validator: passwordValidator,
            obscureText: true,
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
    bool isValidPass = passwordValidator(controller.text) == null;
    if (isValidPass) widget.onSubmit(controller.text);
  }
}
