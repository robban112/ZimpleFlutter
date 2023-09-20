import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/alert_dialog/alert_dialog.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/rectangular_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: appBarSize,
          child: StandardAppBar("Ta bort konto"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Tråkigt att du vill lämna oss! \n\nOm du verkligen är säker på att du vill ta bort ditt konto så tryck på knappen nedan.",
              ),
            ),
            const SizedBox(height: 16),
            RectangularButton(
              onTap: onTapDeleteAccount,
              text: "Ta bort konto",
              color: red,
            ),
          ],
        ));
  }

  void onTapDeleteAccount() async {
    bool answer = await showAlertDialog(
      context: context,
      title: "Är du säker?",
      subtitle: "Om du trycker ja loggas du ut och ditt konto tas bort.",
    );
    if (answer) {
      try {
        FirebaseAuth.instance.currentUser?.delete();
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text("Fel"),
            content: Text("Ett fel inträffade. Logga in igen och försök igen."),
            actions: [
              MaterialButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }
}
