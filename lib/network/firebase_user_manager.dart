import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_parameters.dart';

class FirebaseUserManager {
  String userToken;
  User user;
  FirebaseUserManager() {}

  Future<UserParameters> getUser() {
    user = FirebaseAuth.instance.currentUser;
    return _getUserParameters(user.uid);
  }

  Future<UserParameters> _getUserParameters(String userToken) async {
    final database = FirebaseDatabase.instance.reference();
    print('USER TOKEN: $userToken');
    var snapshot =
        await database.reference().child('Users').child(userToken).once();
    return UserParameters(
        company: snapshot.value['company'],
        isAdmin: snapshot.value['isAdmin'],
        token: userToken,
        email: user.email,
        name: snapshot.value['name']);
  }

  String _getCurrentUserToken() {
    user = FirebaseAuth.instance.currentUser;
    return user.uid;
  }
}
