import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_person_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_user_manager.dart';
import 'package:zimple/screens/Settings/coworkers_screen.dart';
import 'package:zimple/screens/Settings/Customers/customers_screen.dart';
import 'package:zimple/screens/Settings/settings_screen.dart';
import 'package:zimple/screens/Settings/support_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../Login/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/photo_buttons.dart';
import 'package:zimple/widgets/listed_view.dart';

class MoreScreen extends StatefulWidget {
  static const String routeName = "settings_screen";
  final UserParameters user;
  const MoreScreen({required this.user});

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool isSelectingPhotoProvider = false;
  final picker = ImagePicker();
  File? _image;
  bool isLoadingUploadImage = false;

  @override
  void initState() {
    super.initState();
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    pushNewScreenWithRouteSettings(
      context,
      settings: RouteSettings(name: LoginScreen.routeName),
      screen: LoginScreen(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );

    // Navigator.pushNamedAndRemoveUntil(
    //     context, LoginScreen.routeName, (route) => false);
  }

  ListTile buildMenuTile(String title, VoidCallback onTap) {
    return ListTile(title: Text(title), trailing: Icon(Icons.chevron_right), onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 160,
              width: width,
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0))),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 80),
                _buildProfile(),
                SizedBox(height: 10),
                _buildTitle(),
                SizedBox(height: 8),
                widget.user.isAdmin
                    ? Text(
                        "Admin",
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                buildListMenu(context)
              ],
            ),
          ),
          buildPhotoButtons()
        ],
      ),
    );
  }

  Text _buildTitle() {
    String title = widget.user.email.isBlank() ? widget.user.name : widget.user.email;
    return Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  Widget buildListMenu(BuildContext context) {
    return ListedView(
      rowInset: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      items: [
        ListedItem(
            leadingIcon: Icons.people_alt_outlined,
            trailingIcon: Icons.chevron_right,
            text: "Kunder",
            onTap: () {
              pushNewScreen(context, screen: CustomerScreen(customers: ManagerProvider.of(context).customers));
            }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.people,
            text: "Medarbetare",
            onTap: () {
              pushNewScreen(context, screen: CoworkersScreen());
            }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.support_agent,
            text: "Support",
            onTap: () {
              pushNewScreen(context, screen: SupportScreen());
            }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.settings,
            text: "Inställningar",
            onTap: () {
              pushNewScreen(context, screen: SettingsScreen());
            }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.logout,
            text: "Logga ut",
            onTap: () {
              logout(context);
            }),
      ],
    );
  }

  PhotoButtons buildPhotoButtons() {
    return PhotoButtons(
      isSelectingPhotoProvider: this.isSelectingPhotoProvider,
      didTapCancel: () {
        setState(() {
          this.isSelectingPhotoProvider = false;
        });
      },
      didReceiveImage: (file) {
        setState(() {
          this.isLoadingUploadImage = true;
          this._image = file;
        });
        this._uploadProfileImage(file).then((value) {
          setState(() {
            this.isLoadingUploadImage = false;
          });
        });
      },
    );
  }

  Future<void> _uploadProfileImage(File file) async {
    final fbStorageManager = FirebaseStorageManager(company: widget.user.company);
    final fbUserManager = FirebaseUserManager();
    final fbPersonManager = FirebasePersonManager(company: widget.user.company);
    var url = await fbStorageManager.uploadUserProfileImage(file, widget.user);
    await fbPersonManager.setUserProfileImage(widget.user, url);
    return fbUserManager.setUserProfileImage(widget.user, url);
  }

  FutureBuilder _profilePicture() {
    var _future = FirebaseStorageManager(company: widget.user.company).getImage(widget.user.profilePicturePath!);
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return Container();
            }
            return snapshot.data;
          } else {
            return Padding(
              padding: const EdgeInsets.all(60.0),
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  CircleAvatar _buildProfile() {
    var imageNull = widget.user.profilePicturePath == null;
    bool isDarkMode = ThemeNotifier.of(context).isDarkMode();
    return CircleAvatar(
      radius: 75,
      backgroundColor: Colors.grey.shade900,
      child: Stack(
        children: [
          Center(
            child: imageNull
                ? Icon(Icons.image, size: 48)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: Container(
                        width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle), child: _profilePicture()),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                backgroundColor: Colors.grey.shade800,
                mini: true,
                child: Icon(Icons.photo_camera, color: Colors.white),
                onPressed: () {
                  setState(() {
                    this.isSelectingPhotoProvider = !this.isSelectingPhotoProvider;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  String _userName() {
    return widget.user.name.isEmpty ? widget.user.email : widget.user.name;
  }
}
