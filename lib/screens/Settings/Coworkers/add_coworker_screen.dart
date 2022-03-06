import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/src/overlay_controller_widget_extension.dart';
import 'package:provider/src/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_user_manager.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/encrypter.dart';
import 'package:zimple/widgets/listed_view/listed_view.dart';
import 'package:zimple/widgets/widgets.dart';

class AddCoworkerScreen extends StatefulWidget {
  const AddCoworkerScreen({Key? key}) : super(key: key);

  @override
  State<AddCoworkerScreen> createState() => _AddCoworkerScreenState();
}

class _AddCoworkerScreenState extends State<AddCoworkerScreen> {
  bool _hasError = false;

  bool _successfulInvite = false;

  bool _loading = false;

  String errorMessage = "Det blev något fel";

  String? randomToken;

  String iosMagicLink = '';

  String androidMagicLink = '';

  TextEditingController _nameController = TextEditingController();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: appBarSize, child: StandardAppBar('Bjud in')),
      body: BackgroundWidget(child: _body(context)),
    );
  }

  GestureDetector _body(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: _successfulInvite
          ? _SucessInvite(iosMagicLink: this.iosMagicLink, androidMagicLink: this.androidMagicLink)
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ListedView(
                        items: [
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
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildErrorMessage(),
                    ],
                  ).padding(vertical: 8),
                ),
                _buildInviteButton()
              ],
            ),
    );
  }

  Align _buildInviteButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Expanded(
              child: RectangularButton(
                onTap: _onTapAddUser,
                text: 'Lägg till användare',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return _hasError
        ? Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red,
            ),
          )
        : Container();
  }

  String? _validateInput() {
    if (_nameController.text.isEmpty) return "Skriv ett namn";
    if (_emailController.text.isEmpty) return "Skriv in ett email";
    if (!validateEmail(_emailController.text)) return "Skriv in en korrekt e-post";
    return null;
  }

  bool validateEmail(String email) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }

  void _onTapAddUser() {
    String? validateString = _validateInput();
    if (validateString != null)
      setState(() {
        errorMessage = validateString;
        _hasError = true;
      });
    else {
      setState(() {
        _hasError = false;
      });
      setLoading(true);
      FirebaseUserManager fbUserManager = context.read<ManagerProvider>().firebaseUserManager;
      UserParameters user = context.read<ManagerProvider>().user;
      randomToken = Uuid().v4().toString();
      //randomToken = 'Password123Zimple321';
      fbUserManager
          .inviteUser(
              companyId: user.company,
              name: _nameController.text,
              token: randomToken!,
              email: _emailController.text,
              iOSLink: _getIOSMagicLink(_emailController.text, randomToken!),
              androidLink: _getAndroidMagicLink(_emailController.text, randomToken!))
          .then(
        (_) {
          setLoading(false);
          _onSuccessfulInvite();
        },
      );
    }
  }

  void setLoading(bool loading) {
    if (loading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }
  }

  void _onSuccessfulInvite() {
    String email = _emailController.text;
    String token = randomToken!;
    String encryptedEmail = TextEncrypter.encryptText(email);
    String encryptedPass = TextEncrypter.encryptText(token);
    String androidMagicLink = "https://com.zimple.zimple/first-sign-in?email=$encryptedEmail&token=$encryptedPass";
    String iosMagicLink = "com.zimpleflutter.zimple://zimple/first-sign-in?email=$encryptedEmail&token=$encryptedPass";
    print("iOS Magic Link: $iosMagicLink");
    print("Android Magic Link: $androidMagicLink");

    setState(() {
      this.iosMagicLink = iosMagicLink;
      this.androidMagicLink = androidMagicLink;
      this._successfulInvite = true;
    });
  }

  String _getIOSMagicLink(String email, String token) {
    String encryptedEmail = TextEncrypter.encryptText(email);
    String encryptedPass = TextEncrypter.encryptText(token);
    return "com.zimpleflutter.zimple://zimple/first-sign-in?email=$encryptedEmail&token=$encryptedPass";
  }

  String _getAndroidMagicLink(String email, String token) {
    String encryptedEmail = TextEncrypter.encryptText(email);
    String encryptedPass = TextEncrypter.encryptText(token);
    return "https://com.zimple.zimple/first-sign-in?email=$encryptedEmail&token=$encryptedPass";
  }
}

class _SucessInvite extends StatelessWidget {
  final String iosMagicLink;
  final String androidMagicLink;
  const _SucessInvite({
    Key? key,
    required this.iosMagicLink,
    required this.androidMagicLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text("Lyckad inbjudning!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 16),
            // Text(
            //   "Vi har nu skapat en ny användare i vår databas och ett konto för användaren.\nSe hur du loggar in personen nedan",
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 16),
            _buildStepGuide(context),
            const SizedBox(height: 32),
            _buildMagicLink(context, "iOS:", iosMagicLink),
            const SizedBox(height: 16),
            _buildMagicLink(context, "Android:", androidMagicLink),
          ],
        ),
      ),
    );
  }

  Widget _buildStepGuide(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        children: [
          _buildStep(context, 'Kopiera den magiska länken - iOS eller Android', 1),
          const SizedBox(height: 16),
          _buildStep(context, 'Be användaren ladda ner Zimple appen', 2),
          const SizedBox(height: 16),
          _buildStep(context, 'Användaren kan nu trycka på länken för att logga in automatiskt', 3),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String text, int step) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              text,
              overflow: TextOverflow.clip,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMagicLink(BuildContext context, String title, String magicLink) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        SizedBox(width: 56),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            FlutterClipboard.copy(magicLink).then((_) {
              final snackBar = SnackBar(
                content: Text('Kopierat!'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Kopiera'),
          ),
        ),
      ],
    );
  }
}
