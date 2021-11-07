import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zimple/screens/tab_bar_controller.dart';
import 'package:zimple/utils/encrypter.dart';

class FirstLoginScreen extends StatefulWidget {
  static const routeName = 'first_login_screen';
  final String email;
  final String token;
  const FirstLoginScreen({
    Key? key,
    required this.email,
    required this.token,
  }) : super(key: key);

  @override
  _FirstLoginScreenState createState() => _FirstLoginScreenState();
}

class _FirstLoginScreenState extends State<FirstLoginScreen> {
  bool _hasError = false;

  @override
  void initState() {
    loginUser(widget.email, widget.token);
    super.initState();
  }

  void loginUser(String email, String password) async {
    String decryptedEmail = TextEncrypter.decryptText(email.replaceAll(' ', '+'));
    String decryptedPass = TextEncrypter.decryptText(password.replaceAll(' ', '+'));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: decryptedEmail.trim(), password: decryptedPass.trim());
      Navigator.pushNamedAndRemoveUntil(context, TabBarController.routeName, (route) => false);
    } catch (e) {
      setState(() {
        this._hasError = true;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          _buildBackButton(),
          !_hasError
              ? Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 64),
                      Text("Välkommen till Zimple", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Försöker att logga in dig", style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                    ],
                  ),
                )
              : Container(),
          !_hasError ? Center(child: CircularProgressIndicator()) : Container(),
          _hasError ? _buildError() : Container(),
        ],
      ),
    ));
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Ett fel inträffade", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            "Försök gå tillbaka till inloggningssidan och logga in med ditt lösenord. Om du inte har ett lösenord så tryck på 'Glömt ditt lösenord' för att få ett nytt lösenord",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
