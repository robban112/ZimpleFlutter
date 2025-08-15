import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_person_manager.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_user_manager.dart';
import 'package:zimple/screens/Settings/CompanySettings/company_settings_screen.dart';
import 'package:zimple/screens/Settings/Coworkers/add_coworker_screen.dart';
import 'package:zimple/screens/Settings/Customers/customers_screen.dart';
import 'package:zimple/screens/Settings/DrivingRecord/driving_record_screen.dart';
import 'package:zimple/screens/Settings/coworkers_screen.dart';
import 'package:zimple/screens/Settings/settings_screen.dart';
import 'package:zimple/screens/Settings/support_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/service/user_service.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class MoreScreen extends StatefulWidget {
  static const String routeName = "settings_screen";
  final UserParameters user;
  final Future<void> Function() onLogout;
  const MoreScreen({required this.user, required this.onLogout});

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool isSelectingPhotoProvider = false;

  final picker = ImagePicker();

  File? overrideUserImage;

  bool isLoadingUploadImage = false;

  Future<Image?>? _future;

  @override
  void initState() {
    if (widget.user.profilePicturePath != null) {
      this._future = FirebaseStorageManager(company: widget.user.company).getImage(widget.user.profilePicturePath!);
    }
    super.initState();
  }

  void logout(BuildContext context) async {
    await widget.onLogout();
  }

  ListTile buildMenuTile(String title, VoidCallback onTap) {
    return ListTile(title: Text(title), trailing: Icon(Icons.chevron_right), onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(CompanySettings.of(context).companyName.capitalize(), withBackButton: false),
      body: Stack(
        children: [BackgroundWidget(child: _body(context)), buildPhotoButtons()],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          _buildProfile(),
          const SizedBox(height: 12),
          _buildTitle(),
          const SizedBox(height: 4),
          widget.user.isAdmin
              ? Text(
                  "Admin",
                  textAlign: TextAlign.center,
                )
              : Container(),
          const SizedBox(height: 12),
          buildListMenu(context)
        ],
      ),
    );
  }

  Text _buildTitle() {
    String _title = "Test";
    print(widget.user);
    String title = widget.user.email.isBlank() ? widget.user.name : widget.user.email;
    return Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));
  }

  Widget buildListMenu(BuildContext context) {
    return ListedView(
      rowInset: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      items: [
        if (widget.user.isAdmin)
          ListedItem(
              trailingIcon: Icons.chevron_right,
              leadingIcon: FeatherIcons.info,
              text: "Företagsinfo",
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(context, screen: CompanySettingsScreen());
              }),
        ListedItem(
            leadingIcon: Icons.people_alt_outlined,
            trailingIcon: Icons.chevron_right,
            text: "Kunder",
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: CustomerScreen(customers: ManagerProvider.of(context).customers));
            }),
        ListedItem(
            leadingIcon: FontAwesomeIcons.car,
            trailingIcon: Icons.chevron_right,
            text: "Körjournal",
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context, screen: DrivingRecordScreen());
            }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.people,
            text: "Medarbetare",
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context, screen: CoworkersScreen());
            }),
        if (widget.user.isAdmin)
          ListedItem(
              trailingIcon: Icons.chevron_right,
              leadingIcon: Icons.people,
              text: "Bjud in användare",
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(context, screen: AddCoworkerScreen());
              }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.support_agent,
            text: "Support",
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context, screen: SupportScreen());
            }),
        ListedItem(
            trailingIcon: Icons.chevron_right,
            leadingIcon: Icons.settings,
            text: "Inställningar",
            onTap: () {
              PersistentNavBarNavigator.pushNewScreen(context, screen: SettingsScreen(onLogout: widget.onLogout));
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
          this.overrideUserImage = file;
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
    setState(() {
      overrideUserImage = file;
      isLoadingUploadImage = true;
      this.isSelectingPhotoProvider = false;
    });
    final fbStorageManager = FirebaseStorageManager(company: widget.user.company);
    final fbUserManager = FirebaseUserManager();
    final fbPersonManager = FirebasePersonManager(company: widget.user.company);
    var url = await fbStorageManager.uploadUserProfileImage(file, widget.user);
    await UserService.of(context).user?.updatePhotoURL(url);
    await fbPersonManager.setUserProfileImage(widget.user, url);
    await ManagerProvider.of(context).profilePictureService?.updateProfilePic(url, file);
    return fbUserManager.setUserProfileImage(widget.user, url);
  }

  Widget _profilePicture() {
    if (overrideUserImage != null) return Image.file(overrideUserImage!);
    Person? loggedInPerson = ManagerProvider.of(context).getLoggedInPerson();
    //return Container();
    if (loggedInPerson == null || loggedInPerson.profilePicturePath == null) return Container();
    return ManagerProvider.of(context).profilePictureService?.getProfilePicture(loggedInPerson.profilePicturePath!) ??
        Container();
  }

  Widget _buildProfile() {
    var imageNull = widget.user.profilePicturePath == null;
    bool isDarkMode = ThemeNotifier.of(context).isDarkMode();
    return Container(
      width: width(context),
      child: Align(
        child: CircleAvatar(
          radius: 75,
          backgroundColor: Colors.grey.shade900,
          child: Stack(
            children: [
              Center(
                child: _userImage(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 100.0, bottom: 8.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                      mini: true,
                      heroTag: 'Nothing',
                      child: Icon(Icons.photo_camera, color: Colors.white, size: 28),
                      onPressed: () {
                        setState(() {
                          this.isSelectingPhotoProvider = !this.isSelectingPhotoProvider;
                        });
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _userImage() {
    if (isLoadingUploadImage) return CircularProgressIndicator();
    return widget.user.profilePicturePath == null
        ? Icon(Icons.image, size: 48)
        : ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: _profilePicture(),
            ),
          );
  }

  String _userName() {
    return widget.user.name.isEmpty ? widget.user.email : widget.user.name;
  }
}
