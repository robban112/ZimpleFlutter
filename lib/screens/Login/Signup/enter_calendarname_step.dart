import 'package:flutter/material.dart';
import 'package:zimple/screens/Login/components/zimpletextfield.dart';
import 'package:zimple/widgets/widgets.dart';

class EnterCalendarNameStep extends StatefulWidget {
  final Function(String) onSubmit;

  final String? calendarName;

  final FocusNode focusNode;

  EnterCalendarNameStep({
    Key? key,
    required this.onSubmit,
    required this.calendarName,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<EnterCalendarNameStep> createState() => _EnterCalendarNameStepState();
}

class _EnterCalendarNameStepState extends State<EnterCalendarNameStep> {
  late final TextEditingController controller = TextEditingController(text: widget.calendarName);

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
          Text("Välj ett kalendernamn", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ZTextfield(
            focusNode: widget.focusNode,
            formKey: formKey,
            inputType: TextInputType.name,
            controller: controller,
            hintText: 'Kalendernamn / Företagsnamn',
            prefixIcon: Icon(Icons.calendar_today),
            validator: calendarNameValidator,
            autoValidateMode: autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
          ),
          //Expanded(child: Container()),
          const SizedBox(height: 24),
          _nextButton()
        ],
      ),
    );
  }

  String? calendarNameValidator(String? value) {
    if (value == null) return null;

    if (value.isEmpty) return '* Skriv in ett namn';
    if (value.length < 3)
      return '* Skriv in ett korrekt namn över 3 bokstäver';
    else
      return null;
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
    bool isValidEmail = calendarNameValidator(controller.text) == null;
    if (isValidEmail) widget.onSubmit(controller.text);
  }
}
