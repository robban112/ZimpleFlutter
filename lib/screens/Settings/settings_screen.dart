import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_person_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_user_manager.dart';
import 'package:zimple/screens/Settings/coworkers_screen.dart';
import 'package:zimple/screens/Settings/customers_screen.dart';
import 'package:zimple/screens/Settings/support_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/conditional_widget.dart';
import 'package:zimple/widgets/future_image_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../Login/login_screen.dart';
import '../../model/destination.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/photo_buttons.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = "settings_screen";
  final UserParameters user;
  final List<Customer> customers;
  const SettingsScreen({this.user, this.customers});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSelectingPhotoProvider = false;
  final picker = ImagePicker();
  File _image;
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

  ListTile buildMenuTile(String title, Function onTap) {
    return ListTile(
        title: Text(title), trailing: Icon(Icons.chevron_right), onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 210,
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0))),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 130),
                _buildProfile(),
                SizedBox(height: 10),
                Text(widget.user.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0)),
                SizedBox(height: 15),
                widget.user.isAdmin
                    ? Text(
                        "Admin",
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      buildMenuTile("Kunder", () {
                        pushNewScreen(context,
                            screen: CustomerScreen(widget.customers));
                      }),
                      buildMenuTile("Medarbetare", () {
                        pushNewScreen(context, screen: CoworkersScreen());
                      }),
                      buildMenuTile("Support", () {
                        pushNewScreen(context, screen: SupportScreen());
                      }),
                      buildMenuTile("Logga ut", () {
                        logout(context);
                      }),
                    ],
                  ),
                )
              ],
            ),
          ),
          PhotoButtons(
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
          )
        ],
      ),
    );
  }

  Future<void> _uploadProfileImage(File file) async {
    final fbStorageManager =
        FirebaseStorageManager(company: widget.user.company);
    final fbUserManager = FirebaseUserManager();
    final fbPersonManager = FirebasePersonManager(company: widget.user.company);
    var url = await fbStorageManager.uploadUserProfileImage(file, widget.user);
    await fbPersonManager.setUserProfileImage(widget.user, url);
    return fbUserManager.setUserProfileImage(widget.user, url);
  }

  FutureBuilder _profilePicture() {
    var _future = FirebaseStorageManager(company: widget.user.company)
        .getImage(widget.user.profilePicturePath);
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
    return CircleAvatar(
      radius: 75,
      backgroundColor: Colors.grey.shade400,
      child: Stack(
        children: [
          Center(
            child: imageNull
                ? Text(widget.user.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 21.0))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(150),
                    child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: _profilePicture()),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                backgroundColor: Colors.grey.shade300,
                mini: true,
                child: Icon(Icons.photo_camera),
                onPressed: () {
                  setState(() {
                    this.isSelectingPhotoProvider =
                        !this.isSelectingPhotoProvider;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
